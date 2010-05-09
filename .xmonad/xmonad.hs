import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import System.IO
import System.Exit
import qualified Data.Map as M
import qualified XMonad.StackSet as W

-- The Main Man of the Hood --
main = do
	h <- spawnPipe "xmobar"
	xmonad $ defaultConfig
		{ manageHook = manageHook'
		, layoutHook = layoutHook'
		, logHook = logHook' h
		, terminal = terminal'
		, focusedBorderColor = focusedBorderColor'
		--, focusFollowsMouse = focusFollowsMouse'
		, normalBorderColor = normalBorderColor'
		, borderWidth = borderWidth'
		, workspaces = workspaces'
		, modMask = modMask'
		, keys = keys'
		}

-- Gotta manage the pirates, Peter Pan
manageHook' :: ManageHook
manageHook' = composeAll
	[ className =? "MPlayer"        --> doFloat
	, className =? "Gimp"           --> doFloat
	, className =? "Tk"		--> doFloat
	, className =? "Eclipse"	--> doShift "5:java"
	]

logHook' :: Handle -> X ()
logHook' h = dynamicLogWithPP $ customPP { ppOutput = hPutStrLn h }

layoutHook' = customLayout

-- Let's pretty everything up
customPP :: PP
customPP = defaultPP
	{ ppTitle = xmobarColor "#0b8bff" "" . shorten 50
	, ppCurrent = xmobarColor "#0b8bff" "" . wrap "[" "]"
	}

normalBorderColor', focusedBorderColor' :: String
--focusedBorderColor' = "#0b8bff"
focusedBorderColor' = "#000000"
focusFollowsMouse' = False
normalBorderColor' = "#000000"

borderWidth' :: Dimension
borderWidth' = 1

-- I like workspaces, alright?
workspaces' :: [WorkspaceId]
workspaces' = ["1:web", "2:code", "3:chat", "4:docs", "5:java", "6:notes"] ++ map show [7 .. 9 :: Int]

-- George Bush doesn't care about xterm people
terminal' :: String
terminal' = "urxvt"

-- My layouts, default for now
customLayout = avoidStruts $ layoutHook defaultConfig

-- Set up my keybindings
keys' conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
	[ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
	, ((modMask,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
	, ((modMask .|. shiftMask, xK_c     ), kill)

	, ((modMask,               xK_space ), sendMessage NextLayout)
	, ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

	, ((modMask,               xK_n     ), refresh)

	-- move focus up or down the window stack
	, ((modMask,               xK_Tab   ), windows W.focusDown)
	, ((modMask .|. shiftMask, xK_Tab   ), windows W.focusUp  )
	, ((modMask,               xK_j     ), windows W.focusDown)
	, ((modMask,               xK_k     ), windows W.focusUp  )
	, ((modMask,               xK_m     ), windows W.focusMaster  )

	-- modifying the window order
	, ((modMask,               xK_Return), windows W.swapMaster)
	, ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )
	, ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )

	-- resizing the master/slave ratio
	, ((modMask,               xK_h     ), sendMessage Shrink)
	, ((modMask,               xK_l     ), sendMessage Expand)

	-- floating layer support
	, ((modMask,               xK_t     ), withFocused $ windows . W.sink)

	-- increase or decrease number of windows in the master area
	, ((modMask              , xK_comma ), sendMessage (IncMasterN 1))
	, ((modMask              , xK_period), sendMessage (IncMasterN (-1)))

	-- quit, or restart
	, ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
	, ((modMask              , xK_q     ), restart "xmonad" True)
	-- Custom Key Bindings
	-- --
	-- Change to QWERTY/Colemak
	, ((modMask .|. mod1Mask, xK_k), spawn "sh ~/Scripts/keyboard.sh -c")
	-- Toggle my SOCKS proxy
	, ((modMask .|. mod1Mask, xK_s), spawn "sh ~/Scripts/socks.sh -c")
	-- Show the Power Panel
	, ((modMask .|. mod1Mask, xK_Delete), spawn "python ~/Programming/Python/powerPanel.py")
	-- Lock the Screen
	, ((modMask .|. mod1Mask, xK_l), spawn "xscreensaver-command -lock")
	-- Volume control
	, ((0, 0x1008ff12), spawn "amixer -q set Master toggle")
	, ((0, 0x1008ff11), spawn "amixer -q set Master 2- unmute")
	, ((0, 0x1008ff13), spawn "amixer -q set Master 2+ unmute")
	]
	++
	-- mod-[1..9] %! Switch to workspace N
	-- mod-shift-[1..9] %! Move client to workspace N
	[ ((m .|. modMask, k), windows $ f i) | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
	, (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
	]
modMask' :: KeyMask
modMask' = mod4Mask
