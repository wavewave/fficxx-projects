module Main where

import Data.Bits ((.|.))
import Foreign.C.String (newCString)
import System.IO (hPutStrLn,stderr)

import STD.CppString
import STD.Deletable (delete)
import OGDF.Graph
import OGDF.GraphAttributes
import OGDF.GraphIO
import OGDF.LayoutModule
import OGDF.MedianHeuristic
import OGDF.OptimalHierarchyLayout
import OGDF.OptimalRanking
import OGDF.SugiyamaLayout

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


main :: IO ()
main = do
  g <- newGraph
  putStrLn "g created"
  ga <- newGraphAttributes g (   nodeGraphics
                             .|. edgeGraphics
                             .|. nodeLabel
                             .|. edgeStyle
                             .|. nodeStyle
                             .|. nodeTemplate )
  putStrLn "ga created"

  cstr <- newCString "unix-history.gml"
  str <- newCppString cstr
  b <- graphIO_readGML ga g str

  if (b == 0)
    then hPutStrLn stderr "Could not load unix-history.gml"
    else do
      sl <- newSugiyamaLayout
      putStrLn "sl created"
      or <- newOptimalRanking
      putStrLn "or created"
      sugiyamaLayout_setRanking sl or
      putStrLn "setRanking done"
      mh <- newMedianHeuristic
      putStrLn "mh created"
      sugiyamaLayout_setCrossMin sl mh
      putStrLn "setCrossMin"

      ohl <- newOptimalHierarchyLayout
      putStrLn "ohl created"
      optimalHierarchyLayout_layerDistance ohl 30.0
      optimalHierarchyLayout_nodeDistance ohl 25.0
      optimalHierarchyLayout_weightBalancing ohl 0.8
      sugiyamaLayout_setLayout sl ohl
      putStrLn "setLayout ohl"
      call sl ga
      putStrLn "SL.call(GA)"
      cstrout <- newCString "unix-history-layout.gml"
      strout <- newCppString cstrout
      graphIO_writeGML ga strout
      delete strout
      delete sl
      pure ()

  delete g
  delete ga
  delete str
