{-# LANGUAGE ScopedTypeVariables #-}
module Main where

import Data.Bits ((.|.))
import Data.Foldable (forM_)
import Foreign.C.String (withCString)
import Foreign.C.Types
import Foreign.Ptr
import Foreign.Storable

import STD.CppString
import STD.Deletable
import OGDF.DPoint
import OGDF.DPolyline
import OGDF.EdgeElement
import OGDF.Graph
import OGDF.GraphAttributes
import OGDF.GraphIO
import OGDF.NodeElement

nodeGraphics     = 0x000001
edgeGraphics     = 0x000002
edgeIntWeight    = 0x000004
edgeDoubleWeight = 0x000008
edgeLabel        = 0x000010
nodeLabel        = 0x000020
edgeType         = 0x000040
nodeType         = 0x000080
nodeId           = 0x000100
edgeArrow        = 0x000200
edgeStyle        = 0x000400
nodeStyle        = 0x000800
nodeTemplate     = 0x001000
edgeSubGraphs    = 0x002000
nodeWeight       = 0x004000
threeD           = 0x010000

len = 11

main :: IO ()
main = do
  g <- newGraph
  ga <- newGraphAttributes g (nodeGraphics .|. edgeGraphics)

  forM_ [1 .. len-1] $ \i -> do
    left <- graph_newNode g
    p_x1 <- graphAttributes_x ga left
    poke p_x1 (fromIntegral (-5*(i+1)))
    p_y1 <- graphAttributes_y ga left
    poke p_y1 (fromIntegral (-20*i))
    p_width1 <- graphAttributes_width ga left
    poke p_width1 (fromIntegral (10*(i+1)))
    p_height1 <- graphAttributes_height ga left
    poke p_height1 15

    bottom <- graph_newNode g
    p_x2 <- graphAttributes_x ga bottom
    poke p_x2 (fromIntegral (20*(len-i)))
    p_y2 <- graphAttributes_y ga bottom
    poke p_y2 (fromIntegral (5*(len+1-i)))
    p_width2 <- graphAttributes_width ga bottom
    poke p_width2 15
    p_height2 <- graphAttributes_height ga bottom
    poke p_height2 (fromIntegral (10*(len+1-i)))

    e <- graph_newEdge g left bottom
    poly <- graphAttributes_bends ga e
    pt1 <- newDPoint 10 (fromIntegral (-20*i))
    pt2 <- newDPoint (fromIntegral (20*(len-i))) (-10)
    dPolyline_pushBack poly pt1
    dPolyline_pushBack poly pt2


  withCString "manual_graph.gml" $ \cstr -> do
    str <- newCppString cstr
    graphIO_writeGML ga str
    delete str

  delete ga
  delete g
  pure ()
