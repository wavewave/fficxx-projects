{-# LANGUAGE FlexibleInstances   #-}
{-# LANGUAGE MultiWayIf          #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Control.Monad.Loops ( whileM, whileJust_ )
import Data.Foldable    ( for_ )
import Data.String      ( IsString(fromString) )
import qualified Data.Vector.Generic as VG
import qualified Data.Vector.Storable as VS
import qualified Data.Vector as V
import Foreign.C.String ( CString, newCString, peekCAString )
import Foreign.C.Types  ( CDouble, CUInt )
import Foreign.ForeignPtr ( newForeignPtr_ )
import Foreign.Marshal.Array ( allocaArray )
import Foreign.Marshal.Utils ( toBool )
import Foreign.Ptr      ( Ptr, castPtr, nullPtr )
import Foreign.Storable ( Storable(alignment) )
import System.IO.Unsafe ( unsafePerformIO )
--
import GDAL
import GDAL.OGREnvelope.Implementation ( oGREnvelope_MinX_get
                                       , oGREnvelope_MaxX_get
                                       , oGREnvelope_MinY_get
                                       , oGREnvelope_MaxY_get
                                       )

instance IsString CString where
  fromString s = unsafePerformIO $ newCString s


-- some enum definition

gDAL_OF_VECTOR :: CUInt
gDAL_OF_VECTOR = 4

oFTInteger :: CUInt
oFTInteger = 0

oFTIntegerList :: CUInt
oFTIntegerList = 1

oFTString :: CUInt
oFTString = 4

oFTInteger64 :: CUInt
oFTInteger64 = 12


wkbPolygon :: CUInt
wkbPolygon = 3

wkbMultiPolygon :: CUInt
wkbMultiPolygon = 6

-- end of enum


withVectorFromRing :: OGRLinearRing -> ((VS.Vector CDouble, VS.Vector CDouble) -> IO a) -> IO a
withVectorFromRing poRing action = do
  nPoints <- fromIntegral <$> getNumPoints poRing
  let stride = fromIntegral (alignment (undefined :: CDouble))
  allocaArray nPoints $ \(px :: Ptr CDouble) ->
    allocaArray nPoints $ \(py :: Ptr CDouble) -> do
      oGRSimpleCurve_getPoints
        (upcastOGRSimpleCurve poRing)
        (castPtr px)
        stride
        (castPtr py)
        stride
        nullPtr
        0
      fpx <- newForeignPtr_ px
      fpy <- newForeignPtr_ py
      let vx = VS.unsafeFromForeignPtr0 fpx nPoints
          vy = VS.unsafeFromForeignPtr0 fpy nPoints
      action (vx,vy)

main :: IO ()
main = do
  putStrLn "testing hgdal"
  gDALAllRegister
  poDS <- gDALOpenEx ("tl_2019_us_state.shp"::CString) gDAL_OF_VECTOR nullPtr nullPtr nullPtr
  n1 <- getLayerCount poDS
  putStrLn $ "getLayerCount poDS = " ++ show n1

  poLayer <- getLayer poDS 0
  n2 <- getFeatureCount poLayer 1
  putStrLn $ "getFeatureCount poLayer = " ++ show n2

  poFDefn <- getLayerDefn poLayer
  n3 <- getFieldCount poFDefn
  putStrLn $ "getFieldCount poFDefn = " ++ show n3
  n4 <- getGeomFieldCount poFDefn
  putStrLn $ "getGeomFieldCount poFDefn = " ++ show n4


  resetReading poLayer
  whileJust_ (do p@(OGRFeature p') <- getNextFeature poLayer
                 if p' == nullPtr
                   then pure Nothing
                   else pure (Just p)
             ) $
    \poFeature -> do
      putStrLn "------------------------"
      for_ [0..n3-1] $ \i -> do
        poFieldDfn <- getFieldDefn poFDefn i
        cstr <- oGRFieldDefn_GetNameRef poFieldDfn
        str1 <- peekCAString cstr
        -- putStrLn $ "GetNameRef poFieldDfn = " ++ str
        t <- oGRFieldDefn_GetType poFieldDfn
        str2 <-
          if | t == oFTInteger   -> do
               v <- oGRFeature_GetFieldAsInteger poFeature i
               pure (show v)
             | t == oFTString    -> do
               v <- oGRFeature_GetFieldAsString poFeature i
               v' <- peekCAString v
               pure v'
             | t == oFTInteger64 -> do
               v <- oGRFeature_GetFieldAsInteger64 poFeature i
               pure (show v)
             | otherwise         -> pure "otherwise"
        putStrLn $ str1 ++ " = " ++ str2
      poGeometry <- oGRFeature_GetGeometryRef poFeature
      t' <- getGeometryType poGeometry
      str3 <-
        if | t' == wkbPolygon      -> do
             poPoly <- oGRGeometry_toPolygon poGeometry
             poRing <- oGRPolygon_getExteriorRing poPoly

             {-
             -- slow method
             iter <- getPointIterator poRing
             p <- newOGRPoint
             xys <-
               whileM (toBool <$> getNextPoint iter p) $ do
                 x <- oGRPoint_getX p
                 y <- oGRPoint_getY p
                 pure (x,y)
             print xys
             -}
             -- fast method
             -- withVectorFromRing poRing $ \(vx,vy) ->
             --   print $ V.zip (VG.convert vx) (VG.convert vy)
             poEnv <- newOGREnvelope
             getEnvelope poPoly poEnv
             xmin <- oGREnvelope_MinX_get poEnv
             xmax <- oGREnvelope_MaxX_get poEnv
             ymin <- oGREnvelope_MinY_get poEnv
             ymax <- oGREnvelope_MaxY_get poEnv
             pure ("wkbPolygon: " ++ show ((xmin,ymin),(xmax,ymax)))
           | t' == wkbMultiPolygon -> do
               poMPoly <- oGRGeometry_toMultiPolygon poGeometry
               n <- oGRGeometryCollection_getNumGeometries (upcastOGRGeometryCollection poMPoly)
               putStrLn "===============================+"
               print n
               for_ [0..n-1] $ \i -> do
                 putStrLn "***"
                 g <- oGRGeometryCollection_getGeometryRef (upcastOGRGeometryCollection poMPoly) i
                 g' <- oGRGeometry_toPolygon g
                 l <- oGRPolygon_getExteriorRing g'
                 withVectorFromRing l $ \(vx,vy) ->
                   print $ V.zip (VG.convert vx) (VG.convert vy)
                 -- np <- getNumPoints l
                 -- print np
               putStrLn "===============================+"
               pure "wkbMultiPolygon"
           | otherwise             -> pure "otherwise"

      print str3
  pure ()
