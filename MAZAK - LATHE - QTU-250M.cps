var modelType = "QTU 250-M";
description = "KT - Mazak QTU 250-M ";
// >>>>> INCLUDED FROM ../common/mazak mill-turn.cps

//Save This line for editing purposes, comment out before merge
//var modelType = "QUICK TURN 250-M";
//var modelType = "QTU 250-MSY";

/**
  Copyright (C) 2012-2023 by Autodesk, Inc.
  All rights reserved.

  Mazak Quickturn lathe post processor configuration.

  $Revision: 2 $
  $Date: 2023-10-18 19:22:41 $

 

  Updates

  V1. Orginal Post# 44093 aecd2ebd4f8b23a548aa359ba5bebab1a29d7994

  V1.5 ORG_FORKID {086A02EF-4920-4866-9BB6-2F08579DD109}

  V2. Adam 2-13-2024
    -Added user name, date and time of program post

 
*/

///////////////////////////////////////////////////////////////////////////////
//                        MANUAL NC COMMANDS
//
// The following ACTION commands are supported by this post.
//
//     partEject                       - Manually eject the part
//     transferType:phase,speed,stop   - Phase or Speed spindle synchronization for stock-transfer
//     transferUseTorque:yes,no   - Use torque control for stock-transfer
//     usePolarInterpolation      - Force Polar interpolation mode for next operation (usePolarMode is deprecated but still supported)
//     usePolarCoordinates        - Force Polar coordinates for the next operation (useXZCMode is deprecated but still supported)
//
// Note: Enter the Tool ID Code in the Product ID of the Tool. Leave Blank if not used
///////////////////////////////////////////////////////////////////////////////

if (!description) {
  description = "Mazak Quick turn/QTU lathe post processor configuration";
}
vendor = "Mazak";
vendorUrl = "https://www.mazak.com/";
legal = "Copyright (C) 2012-2023 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45909;

if (!longDescription) {
  longDescription = subst("Preconfigured %1 post (Smooth/Matrix/640MT control) with support for mill-turn. Enter the Tool ID Code in the Product ID of the Tool. Leave Blank if not used", description);
}

extension = "EIA";
programNameIsInteger = true;
setCodePage("ascii");
capabilities = CAPABILITY_MILLING | CAPABILITY_TURNING;

tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.01, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(120); // reduced sweep due to G112 support
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion
allowSpiralMoves = false;
allowFeedPerRevolutionDrilling = true;
highFeedrate = (unit == IN) ? 470 : 12000;

// user-defined properties
properties = {
  writeMachine: {
    title      : "Write machine",
    description: "Output the machine settings in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  writeTools: {
    title      : "Write tool list",
    description: "Output a tool list in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  maxTool: {
    title      : "Max tool number",
    description: "Defines the maximum tool number.",
    group      : "configuration",
    type       : "integer",
    range      : [0, 999999999],
    value      : 12,
    scope      : "post"
  },
  showSequenceNumbers: {
    title      : "Use sequence numbers",
    description: "'Yes' outputs sequence numbers on each block, 'Only on tool change' outputs sequence numbers on tool change blocks only, and 'No' disables the output of sequence numbers.",
    group      : "formats",
    type       : "enum",
    values     : [
      {title:"Yes", id:"true"},
      {title:"No", id:"false"},
      {title:"Only on tool change", id:"toolChange"}
    ],
    value: "toolChange",
    scope: "post"
  },
  sequenceNumberStart: {
    title      : "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group      : "formats",
    type       : "integer",
    value      : 1,
    scope      : "post"
  },
  sequenceNumberIncrement: {
    title      : "Sequence number increment",
    description: "The amount by which the sequence number is incremented by in each block.",
    group      : "formats",
    type       : "integer",
    value      : 1,
    scope      : "post"
  },
  optionalStop: {
    title      : "Optional stop",
    description: "Outputs optional stop code during when necessary in the code.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  separateWordsWithSpace: {
    title      : "Separate words with space",
    description: "Adds spaces between words if 'yes' is selected.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useRadius: {
    title      : "Radius arcs",
    description: "If yes is selected, arcs are outputted using radius values rather than IJK.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  maximumSpindleSpeed: {
    title      : "Max spindle speed",
    description: "Defines the maximum spindle speed allowed by your machines.",
    group      : "configuration",
    type       : "integer",
    range      : [0, 999999999],
    value      : 6000,
    scope      : "post"
  },
  useParametricFeed: {
    title      : "Parametric feed",
    description: "Specifies the feed value that should be output using a Q value.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  showNotes: {
    title      : "Show notes",
    description: "Writes operation notes as comments in the outputted code.",
    group      : "formats",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useCycles: {
    title      : "Use cycles",
    description: "Specifies if canned drilling cycles should be used.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  usePartCatcher: {
    title      : "Use part catcher",
    description: "Specifies whether part catcher code should be output.",
    group      : "configuration",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  autoEject: {
    title      : "Auto eject",
    description: "Specifies whether the part should automatically eject at the end of a program.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useTailStock: {
    title       : "Use tailstock",
    description : "Specifies whether to use the tailstock or not.",
    group       : "configuration",
    type        : "boolean",
    presentation: "yesno",
    value       : false,
    scope       : "post"
  },
  xAxisMinimum: {
    title      : "X-axis minimum limit",
    description: "Defines the lower limit of X-axis travel as a radius value.",
    group      : "configuration",
    type       : "spatial",
    range      : [-99999, 0],
    value      : 0,
    scope      : "post"
  },
  useG53Zhome: {
    title       : "Use G53 Z home",
    description : "Specifies whether to use a G53 Z home position.",
    group       : "homePositions",
    type        : "boolean",
    presentation: "yesno",
    value       : true,
    scope       : "post"
  },
  homePositionZ: {
    title      : "Z home position",
    description: "Z home position, only output if Use G53 Z Home is not used.",
    group      : "homePositions",
    type       : "number",
    value      : 0,
    scope      : "post"
  },
  transferType: {
    title      : "Transfer type",
    description: "Phase, speed synchronization for stock-transfer.",
    group      : "preferences",
    type       : "enum",
    values     : [
      "Phase",
      "Speed"
    ],
    value: "Phase",
    scope: "post"
  },
  transferTool: {
    title      : "Transfer Tool Number",
    description: "Defines the tool called when secondary spindle chuck process happens",
    group      : "preferences",
    type       : "number",
    range      : [0, 999999999],
    value      : 1212.01,
    scope      : "post"
  },
  optimizeCAxisSelect: {
    title      : "Optimize C axis selection",
    description: "Optimizes the output of enable/disable C-axis codes.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  transferUseTorque: {
    title      : "Stock-transfer torque control",
    description: "Use torque control for stock transfer.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  looping: {
    title       : "Use M98 looping",
    description : "Output program for M98 looping.",
    group       : "looping",
    type        : "boolean",
    presentation: "yesno",
    value       : false,
    scope       : "post"
  },
  numberOfRepeats: {
    title      : "Number of repeats",
    description: "How many times to loop the program.",
    group      : "looping",
    type       : "integer",
    range      : [0, 99999999],
    value      : 1,
    scope      : "post"
  },
  writeVersion: {
    title      : "Write version",
    description: "Write the version number in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  useRigidTapping: {
    title      : "Use rigid tapping",
    description: "Select 'Yes' to enable, 'No' to disable.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useSimpleThread: {
    title      : "Use simple threading cycle",
    description: "Enable to output G92 simple threading cycle, disable to output G76 standard threading cycle.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useYAxisForDrilling: {
    title      : "Position in Y for axial drilling",
    description: "Positions in Y for axial drilling options when it can instead of using the C-axis.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  isoModeOrMazatrol: {
    title      : "Use ISO Tool Table or Mazatrol",
    description: "Switch for using Maztrol subprogram, tool table and work offsets or full ISO",
    group      : "configuration",
    type       : "enum",
    values     : [
      "ISO",
      "Mazatrol"
    ],
    value: "Mazatrol",
    scope: "post"
  },
  controllerType: {
    title      : "Version of Controller",
    description: "Switch for using a Fusion or Matrix controller",
    type       : "enum",
    group      : "configuration",
    values     : [
      "640MT",
      "Matrix",
      "Smooth"
    ],
    value: "Matrix",
    scope: "post"
  }
};

groupDefinitions = {
  looping: {title:"Looping", collapsed:true, order:25}
};

// wcs definiton
wcsDefinitions = {
  useZeroOffset: false,
  wcs          : [
    {name:"Standard", format:"G", range:[54, 59]}
  ]
};

var singleLineCoolant = false; // specifies to output multiple coolant codes in one line rather than in separate lines
// samples:
// {id: COOLANT_THROUGH_TOOL, on: 88, off: 89}
// {id: COOLANT_THROUGH_TOOL, on: [8, 88], off: [9, 89]}
// {id: COOLANT_THROUGH_TOOL, turret1:{on: [8, 88], off:[9, 89]}, turret2:{on:88, off:89}}
// {id: COOLANT_THROUGH_TOOL, spindle1:{on: [8, 88], off:[9, 89]}, spindle2:{on:88, off:89}}
// {id: COOLANT_THROUGH_TOOL, spindle1t1:{on: [8, 88], off:[9, 89]}, spindle1t2:{on:88, off:89}}
// {id: COOLANT_THROUGH_TOOL, on: "M88 P3 (myComment)", off: "M89"}
var coolants = [
  {id:COOLANT_FLOOD, on:8},
  {id:COOLANT_MIST},
  {id:COOLANT_THROUGH_TOOL, on:88, off:89},
  {id:COOLANT_AIR, spindle1:{on:26, off:27}, spindle2:{on:36, off:37}},
  {id:COOLANT_AIR_THROUGH_TOOL, on:7},
  {id:COOLANT_SUCTION},
  {id:COOLANT_FLOOD_MIST},
  {id:COOLANT_FLOOD_THROUGH_TOOL, on:[8, 88]},
  {id:COOLANT_OFF, off:9}
];

var permittedCommentChars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,=_-/:";

var gFormat = createFormat({prefix:"G", decimals:1});
var g1Format = createFormat({prefix:"G", decimals:1});
var mFormat = createFormat({prefix:"M", decimals:0});

var spatialFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var xFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true, scale:2}); // diameter mode & IS SCALING POLAR COORDINATES
var yFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var zFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var subBFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true, forceSign:true});
var rFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true}); // radius
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var cFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG, cyclicLimit:Math.PI * 2});
var fpmFormat = createFormat({decimals:(unit == MM ? 2 : 3), forceDecimal:true});
var fprFormat = createFormat({type:FORMAT_REAL, decimals:(unit == MM ? 3 : 4), minimum:(unit == MM ? 0.001 : 0.0001)});
var feedFormat = fpmFormat;
var pitchFormat = createFormat({decimals:6, forceDecimal:true});
var toolFormat = createFormat({decimals:0, width:4, zeropad:true});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-99999.999
var milliFormat = createFormat({decimals:0}); // milliseconds // range 1-9999
var taperFormat = createFormat({decimals:1, scale:DEG});
var threadP1Format = createFormat({decimals:0, forceDecimal:false, trim:false, width:6, zeropad:true});
var threadPQFormat = createFormat({decimals:0, forceDecimal:false, trim:true, scale:10000});
var dwellFormat = createFormat({prefix:"U", decimals:3});
var peckFormat = createFormat({type:FORMAT_REAL, decimals:(unit == MM ? 3 : 4)});

var xOutput = createVariable({prefix:"X"}, xFormat);
var yOutput = createVariable({prefix:"Y"}, yFormat);
var zOutput = createVariable({prefix:"Z"}, zFormat);
var subBOutput = createVariable({prefix:"B[#501", force:true}, subBFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, cFormat);
var barOutput = createVariable({prefix:"B", force:true}, spatialFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var pitchOutput = createVariable({prefix:"F", force:true}, pitchFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var pOutput = createVariable({prefix:"P", force:true}, rpmFormat);
var rcssOutput = createVariable({prefix:"R", force:true}, rpmFormat);
var rOutput = createVariable({prefix:"R", force:true}, rFormat);
var threadP1Output = createVariable({prefix:"P", force:true}, threadP1Format);
var threadP2Output = createVariable({prefix:"P", force:true}, threadPQFormat);
var threadQOutput = createVariable({prefix:"Q", force:true}, threadPQFormat);
var threadROutput = createVariable({prefix:"R", force:true}, threadPQFormat);
var threadIOutput = createVariable({prefix:"I", force:true}, threadPQFormat);
var g92ROutput = createVariable({prefix:"R", force:true}, zFormat); // no scaling
var peckOutput = createVariable({prefix:"Q", force:true}, peckFormat);

// circular output
var iOutput = createReferenceVariable({prefix:"I", force:true}, spatialFormat);
var jOutput = createReferenceVariable({prefix:"J", force:true}, spatialFormat);
var kOutput = createReferenceVariable({prefix:"K", force:true}, spatialFormat);

var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G98-99
var gSpindleModeModal = createModal({}, gFormat); // modal group 5 // G96-97
var gSpindleModal = createModal({}, mFormat); // M176/177 SPINDLE MODE
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({}, gFormat); // modal group 9 // G81, ...
var gPolarModal = createModal({}, g1Format); // G12.1, G13.1
var gSelectSpindleModal = createModal({}, mFormat); // G141, G142
var cAxisEngageModal = createModal({}, mFormat);
var cAxisBrakeModal = createModal({}, mFormat);
var mInterferModal = createModal({}, mFormat);

// fixed settings
var firstFeedParameter = 100;
var gotDoorControl = false;
var useG31push = false;
var airCleanChuck = false; // use air to clean off chuck at part transfer and part eject

// defined in defineMachine
var turret1GotYAxis;
var gotYAxis;
var yAxisMinimum;
var yAxisMaximum;
var xAxisMinimum;
var gotBAxis;
var bAxisIsManual;
var gotMultiTurret;
var gotPolarInterpolation;
var gotSecondarySpindle;
var maximumSpindleSpeedLive;

var WARNING_WORK_OFFSET = 0;
var WARNING_REPEAT_TAPPING = 1;

var SPINDLE_MAIN = 0;
var SPINDLE_SUB = 1;
var SPINDLE_LIVE = 2;

var POSX = 0;
var POXY = 1;
var POSZ = 2;
var NEGZ = -2;

var TRANSFER_PHASE = 0;
var TRANSFER_SPEED = 1;
var TRANSFER_STOP = 2;

// getSpindle parameters
var TOOL = false;
var PART = true;

// clampChuck parameters
var CLAMP = true;
var UNCLAMP = false;

// collected state
var sequenceNumber;
var currentWorkOffset;
var optionalSection = false;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var previousSpindle = SPINDLE_MAIN;
var previousPartSpindle = SPINDLE_MAIN;
var activeSpindle = SPINDLE_MAIN;
var partCutoff = false;
var transferType;
var transferUseTorque;
var showSequenceNumbers;
var forcePolarCoordinates = false; // forces XZC output, activated by Action:usePolarCoordinates
var forcePolarInterpolation = false; // force Polar interpolation output, activated by Action:usePolarInterpolation
var tapping = false;
var ejectRoutine = false;
var bestABC = undefined;
var lastSpindleMode = undefined;
var lastSpindleSpeed = 0;
var lastSpindleDirection = undefined;
var activeTurret = 1;
var turret1GotBAxis;  // for storing the initial state of the gotBAxis variable, when switching turret.
var reverseAxes;
var operationSupportsTCP; // multi-axis operation supports TCP

var machineState = {
  isTurningOperation            : undefined,
  liveToolIsActive              : undefined,
  cAxisIsEngaged                : undefined,
  machiningDirection            : undefined,
  mainSpindleIsActive           : undefined,
  subSpindleIsActive            : undefined,
  mainSpindleBrakeIsActive      : undefined,
  subSpindleBrakeIsActive       : undefined,
  tailstockIsActive             : undefined,
  usePolarInterpolation         : undefined,
  usePolarCoordinates           : undefined,
  axialCenterDrilling           : undefined,
  currentBAxisOrientationTurning: new Vector(0, 0, 0),
  mainChuckIsClamped            : undefined,
  subChuckIsClamped             : undefined,
  stockTransferIsActive         : false,
  feedPerRevolution             : undefined
};

function getCode(code, spindle) {
  switch (code) {
  case "PART_CATCHER_ON":
    return 48;
  case "PART_CATCHER_OFF":
    return 49;
  case "TAILSTOCK_ON":
    machineState.tailstockIsActive = true;
    return mFormat.format(741);
  case "TAILSTOCK_OFF":
    machineState.tailstockIsActive = false;
    return mFormat.format(743);
  case "ENABLE_C_AXIS":
    machineState.cAxisIsEngaged = true;
    return (spindle == SPINDLE_MAIN) ? 200 : 300;
  case "DISABLE_C_AXIS":
    machineState.cAxisIsEngaged = false;
    return (spindle == SPINDLE_MAIN) ? 202 : 302;
  case "POLAR_INTERPOLATION_ON":
    return 12.1;
  case "POLAR_INTERPOLATION_OFF":
    return 13.1;
  case "STOP_SPINDLE":
    lastSpindleSpeed = 0;
    lastSpindleDirection = undefined;
    sOutput.reset();
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = false;
      return 5;
    case SPINDLE_SUB:
      machineState.subSpindleIsActive = false;
      return 305;
    case SPINDLE_LIVE:
      machineState.liveToolIsActive = false;
      return 205;
    }
    break;
  case "ORIENT_SPINDLE":
    return (spindle == SPINDLE_MAIN) ? 19 : 39;
  case "START_SPINDLE_CW":
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = true;
      return 3;
    case SPINDLE_SUB:
      machineState.subSpindleIsActive = true;
      return 303;
    case SPINDLE_LIVE:
      machineState.liveToolIsActive = true;
      return 203;
    }
    break;
  case "START_SPINDLE_CCW":
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = true;
      return 4;
    case SPINDLE_SUB:
      machineState.subSpindleIsActive = true;
      return 304;
    case SPINDLE_LIVE:
      machineState.liveToolIsActive = true;
      return 204;
    }
    break;
  case "FEED_MODE_UNIT_REV":
    machineState.feedPerRevolution = true;
    return 99;
  case "FEED_MODE_UNIT_MIN":
    machineState.feedPerRevolution = false;
    return 98;
  case "CONSTANT_SURFACE_SPEED_ON":
    return 96;
  case "CONSTANT_SURFACE_SPEED_OFF":
    return 97;
  case "LOCK_MULTI_AXIS":
    return (spindle == SPINDLE_MAIN) ? 210 : 310;
  case "UNLOCK_MULTI_AXIS":
    return (spindle == SPINDLE_MAIN) ? 212 : 312;
  case "CLAMP_CHUCK":
    return (spindle == SPINDLE_MAIN) ? 207 : 307;
  case "UNCLAMP_CHUCK":
    return (spindle == SPINDLE_MAIN) ? 206 : 306;
  case "SPINDLE_SYNCHRONIZATION_PHASE":
    return 511;
  case "SPINDLE_SYNCHRONIZATION_PHASE_OFF":
    return 513;
  case "SPINDLE_SYNCHRONIZATION_SPEED":
    return getProperty("controllerType") == "640MT" ? 380 : 511;
  case "SPINDLE_SYNCHRONIZATION_SPEED_OFF":
    return getProperty("controllerType") == "640MT" ? 381 : 513;
  case "TORQUE_SKIP_ON":
    return 508;
  case "TORQUE_SKIP_OFF":
    return 509;
  case "ACTIVATE_SPINDLE":
    return (spindle == SPINDLE_MAIN) ? 901 : 902;
  case "SELECT_SPINDLE":
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = true;
      machineState.subSpindleIsActive = false;
      machineState.liveToolIsActive = false;
      return 1;
    /*case SPINDLE_LIVE:
      machineState.mainSpindleIsActive = false;
      machineState.subSpindleIsActive = false;
      machineState.liveToolIsActive = true;
      return false;
      */
    case SPINDLE_SUB:
      machineState.mainSpindleIsActive = false;
      machineState.subSpindleIsActive = true;
      machineState.liveToolIsActive = false;
      return 2;
    }
    break;
  case "RIGID_TAPPING":
    return 29;
  case "INTERLOCK_BYPASS":
    return 31;
  case "INTERLOCK_BYPASS_OFF":
    return 32;
    /*
  case "INTERFERENCE_CHECK_OFF":
    return 110;
  case "INTERFERENCE_CHECK_ON":
    return 111;
*/
  case "CYCLE_PART_EJECTOR":
    return 185;
  case "AIR_BLAST_ON":
    return (spindle == SPINDLE_MAIN) ? 26 : 36;
  case "AIR_BLAST_OFF":
    return (spindle == SPINDLE_MAIN) ? 27 : 37;
  default:
    error(localize("Command " + code + " is not defined."));
    return 0;
  }
  return 0;
}

/**
  Returns the desired tolerance for the given section.
*/
function getTolerance() {
  var t = tolerance;
  if (hasParameter("operation:tolerance")) {
    if (t > 0) {
      t = Math.min(t, getParameter("operation:tolerance"));
    } else {
      t = getParameter("operation:tolerance");
    }
  }
  return t;
}

function formatSequenceNumber() {
  if (sequenceNumber > 99999) {
    sequenceNumber = getProperty("sequenceNumberStart");
  }
  var seqno = "N" + sequenceNumber;
  sequenceNumber += getProperty("sequenceNumberIncrement");
  return seqno;
}

/**
  Writes the specified block.
*/
function writeBlock() {
  var text = formatWords(arguments);
  if (!text) {
    return;
  }
  var seqno = "";
  var opskip = "";
  if (showSequenceNumbers == "true") {
    seqno = formatSequenceNumber();
  }
  if (optionalSection) {
    opskip = "/";
  }
  if (text) {
    writeWords(opskip, seqno, text);
  }
}

function writeDebug(_text) {
  writeComment("DEBUG - " + _text);
}

function formatComment(text) {
  return "(" + String(filterText(String(text).toUpperCase(), permittedCommentChars)).replace(/[()]/g, "") + ")";
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text));
}

function getB(abc, section) {
  if (section.spindle == SPINDLE_PRIMARY) {
    return abc.y;
  } else {
    return Math.PI - abc.y;
  }
}

function writeCommentSeqno(text) {
  writeln(formatSequenceNumber() + formatComment(text));
}

function defineMachine() {
  if (modelType == "QUICK TURN 100-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 100-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 100-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 100-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 200-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 200-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 200-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 200-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 250-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 250-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 250-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 250-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 350-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QUICK TURN 350-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -76.2 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 76.2 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QUICK TURN 350-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -76.2 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 76.2 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QUICK TURN 400-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QUICK TURN 450-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QUICK TURN 450-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -101.6 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 101.6 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QTU 200-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 200-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 200-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 200-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 250-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 250-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 250-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 250-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 350-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 350-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 350-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 350-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "EZ 8M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "EZ 8MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "EZ 8MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "EZ 10M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "EZ 10MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "EZ 10MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "EZ 12M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = false;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "EZ 12MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "EZ 12MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    turret1GotYAxis = true;
    yAxisMinimum = toPreciseUnit(turret1GotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(turret1GotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  }
  xAxisMinimum = getProperty("xAxisMinimum");
}

function activateMachine(section) {
  // TCP setting
  operationSupportsTCP = false;

  // handle multiple turrets
  var turret = 1;
  if (gotMultiTurret) {
    turret = section.getTool().turret;
    if (turret == 0) {
      warningOnce(localize("Turret has not been specified. Using Turret 1 as default."), WARNING_TURRET_UNSPECIFIED);
      turret = 1; // upper turret as default
    }
    turret = turret == undefined ? 1 : turret;
    switch (turret) {
    case 1:
      gotYAxis = turret1GotYAxis;
      gotBAxis = turret1GotBAxis;
      break;
    case 2:
      gotYAxis = turret2GotYAxis;
      gotBAxis = false;
      break;
    default:
      error(subst(localize("Turret %1 is not supported"), turret));
      return turret;
    }
  } else {
    gotYAxis = turret1GotYAxis;
  }

  // disable unsupported rotary axes output
  if (!gotYAxis) {
    yOutput.disable();
  }
  aOutput.disable();

  // define machine configuration
  var bAxis;
  var cAxis;
  if (section.getSpindle() == SPINDLE_PRIMARY) {
    bAxis = createAxis({coordinate:1, table:false, axis:[0, -1, 0], range:[-0.001, 90.001], preference:0});
    cAxis = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0});
  } else {
    bAxis = createAxis({coordinate:1, table:false, axis:[0, -1, 0], range:[-0.001, 180.001], preference:0});
    cAxis = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0});
  }
  if (gotBAxis) {
    machineConfiguration = new MachineConfiguration(bAxis, cAxis);
    bOutput.enable();
  } else {
    machineConfiguration = new MachineConfiguration(cAxis);
    bOutput.disable();
  }

  // define spindle axis
  if (!gotBAxis || bAxisIsManual || (turret == 2)) {
    if ((getMachiningDirection(section) == MACHINING_DIRECTION_AXIAL) && !section.isMultiAxis()) {
      machineConfiguration.setSpindleAxis(new Vector(0, 0, 1));
    } else {
      machineConfiguration.setSpindleAxis(new Vector(1, 0, 0));
    }
  } else {
    machineConfiguration.setSpindleAxis(new Vector(0, 0, 1)); // set the spindle axis depending on B0 orientation
  }

  // define linear axes limits
  var xAxisMaximum = 10000; // don't check X-axis maximum limit
  yAxisMinimum = gotYAxis ? yAxisMinimum : 0;
  yAxisMaximum = gotYAxis ? yAxisMaximum : 0;
  var xAxis = createAxis({actuator:"linear", coordinate:0, table:true, axis:[1, 0, 0], range:[xAxisMinimum, xAxisMaximum]});
  var yAxis = createAxis({actuator:"linear", coordinate:1, table:true, axis:[0, 1, 0], range:[yAxisMinimum, yAxisMaximum]});
  var zAxis = createAxis({actuator:"linear", coordinate:2, table:true, axis:[0, 0, 1], range:[-100000, 100000]});
  machineConfiguration.setAxisX(xAxis);
  machineConfiguration.setAxisY(yAxis);
  machineConfiguration.setAxisZ(zAxis);

  // enable retract/reconfigure
  safeRetractDistance = (unit == IN) ? 1 : 25; // additional distance to retract out of stock, can be overridden with a property
  safeRetractFeed = (unit == IN) ? 20 : 500; // retract feed rate
  safePlungeFeed = (unit == IN) ? 10 : 250; // plunge feed rate
  var stockExpansion = new Vector(toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN)); // expand stock XYZ values
  machineConfiguration.enableMachineRewinds();
  machineConfiguration.setSafeRetractDistance(safeRetractDistance);
  machineConfiguration.setSafeRetractFeedrate(safeRetractFeed);
  machineConfiguration.setSafePlungeFeedrate(safePlungeFeed);
  machineConfiguration.setRewindStockExpansion(stockExpansion);

  // multi-axis feedrates
  machineConfiguration.setMultiAxisFeedrate(
    operationSupportsTCP ? FEED_FPM : FEED_DPM, // FEED_DPM, FEED_INVERSE_TIME,
    4800, // maximum output value for dpm feed rates
    DPM_COMBINATION, // INVERSE_MINUTES/INVERSE_SECONDS or DPM_COMBINATION/DPM_STANDARD
    0.5, // tolerance to determine when the DPM feed has changed
    unit == MM ? 1 : 1 // ratio of rotary accuracy to linear accuracy for DPM calculations
  );

  machineConfiguration.setVendor("Mazak");
  machineConfiguration.setModel(modelType);
  setMachineConfiguration(machineConfiguration);
  if (section.isMultiAxis()) {
    section.optimizeMachineAnglesByMachine(machineConfiguration, 1);
  }

  return turret;
}

function onOpen() {
  // define machine
  defineMachine();
  turret1GotBAxis = gotBAxis;
  activeTurret = activateMachine(getSection(0));

  if (getProperty("useRadius")) {
    maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
  }

  // Copy certain properties into global variables
  showSequenceNumbers = getProperty("showSequenceNumbers");
  transferType = parseToggle(getProperty("transferType"), "PHASE", "SPEED");
  if (transferType == undefined) {
    error(localize("TransferType must be Phase or Speed"));
    return;
  }
  transferUseTorque = getProperty("transferUseTorque");

  if (highFeedrate <= 0) {
    error(localize("You must set 'highFeedrate' because axes are not synchronized for rapid traversal."));
    return;
  }

  reverseAxes = getProperty("reverseAxes", true);

  if (!getProperty("separateWordsWithSpace")) {
    setWordSeparator("");
  }

  sequenceNumber = getProperty("sequenceNumberStart");

  if (programName) {
    var programId;
    try {
      programId = getAsInt(programName);
    } catch (e) {
      error(localize("Program name must be a number."));
      return;
    }
    if (!((programId >= 1) && (programId <= 9999))) {
      error(localize("Program number is out of range."));
      return;
    }
    var oFormat = createFormat({width:4, zeropad:true, decimals:0});
    if (programComment) {
      writeln("O" + oFormat.format(programId) + " (" + filterText(String(programComment).toUpperCase(), permittedCommentChars) + ")");
    } else {
      writeln("O" + oFormat.format(programId) + "( )");
    }
  } else {
    error(localize("Program name has not been specified."));
    return;
  }

  if (getProperty("isoModeOrMazatrol") == "ISO") {
    writeComment("Check F93 bit 3 is 0 and F94 bit 7 is 0 to use ISO Work Offsets and Tool table");
  } else {
    writeComment("Check F93 bit 3 is 1 and F94 bit 7 is 1 to use Mazatrol Work Offsets and Tool table");
    writeComment("Enter the Tool ID Code in the Product ID of the Tool. Leave Blank if not used");

    if (gotSecondarySpindle) {
      writeBlock("#150=0", formatComment("ENTER DISTANCE FROM SUB ORIGIN TO MAIN ORIGIN. USED TO SHIFT ORIGIN FOR WORKING ON SUB"));
      writeBlock("#501=0", formatComment("Enter the Distance from face of the Part on the Main Spindle to the Face of the Jaws on the Sub Spindle"));
    }
  }

  if (getProperty("writeVersion")) {
    if ((typeof getHeaderVersion == "function") && getHeaderVersion()) {
      writeComment(localize("post version") + ": " + getHeaderVersion());
    }
    if ((typeof getHeaderDate == "function") && getHeaderDate()) {
      writeComment(localize("post modified") + ": " + getHeaderDate());
    }
  }

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var mDescription = machineConfiguration.getDescription();

  if (getProperty("writeMachine") && (vendor || model || mDescription)) {
    writeComment(localize(" Machine"));
    if (vendor) {
      writeComment(" " + localize("vendor") + "- " + vendor);
    }
    if (model) {
      writeComment(" " + localize("model") + "- " + modelType);
    }
    if (mDescription) {
      writeComment(" " + localize("description") + "- "  + mDescription);
    }
    writeComment(" " + localize("Controller Type - " + getProperty("controllerType")));
    writeComment(" " + localize("Running in " + getProperty("isoModeOrMazatrol") + " Mode"));
  }


// V2. ADDED USER NAME AND DATE ADC 11-6-24
writeln("");
if (hasGlobalParameter("username")) {
  var User = getGlobalParameter("username");
  writeComment(localize("Username:") + " " + User.toLocaleString());
  }

  var d = new Date();{ // output current date and time
    writeComment(localize("Posted On") + ": " + d.toLocaleDateString() + " " +
    d.toLocaleTimeString());
  }
  


  // End username and date
  // V2. Added user name & date + time adc-2-13-2024
  /*
  // write user name	
  if (hasGlobalParameter("username")) {
    var usernameprint = getGlobalParameter("username");
		  writeln("");
		  writeComment("Username: " + usernameprint);
		  }
		  
  // write date	and time of computer
  {
    const d = new Date();
    const h = d.getHours();
    const hrs_12 = h > 12 ? h - 12 : h;
    const m = d.getMinutes();
    const pm_am = h > 12 ? 'PM' : 'AM';

    writeComment(
      'Posted: ' +
        d.toLocaleDateString() + ' ' +
        hrs_12 + ':' + m + ' ' + pm_am
    )
  
     // writeComment('Posted: ' + new Date().toLocaleString()
    //)
    
  }  
*/
  // dump tool information
  if (getProperty("writeTools")) {
    var zRanges = {};
    if (is3D()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var zRange = section.getGlobalZRange();
        var tool = section.getTool();
        if (zRanges[tool.number]) {
          zRanges[tool.number].expandToRange(zRange);
        } else {
          zRanges[tool.number] = zRange;
        }
      }
    }

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var compensationOffset = tool.isTurningTool() ? tool.compensationOffset : tool.lengthOffset;
        var comment = "T" + toolFormat.format(tool.number * 100 + compensationOffset % 100) + " " +
          "D=" + spatialFormat.format(tool.diameter) + " " +
          localize("CR") + "=" + spatialFormat.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
        }
        if (zRanges[tool.number]) {
          comment += " - " + localize("ZMIN") + "=" + spatialFormat.format(zRanges[tool.number].getMinimum());
        }
        comment += " - " + getToolTypeName(tool.type);
        writeComment(comment);
      }
    }
  }

  if (false) {
    // check for duplicate tool number
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var sectioni = getSection(i);
      var tooli = sectioni.getTool();
      for (var j = i + 1; j < getNumberOfSections(); ++j) {
        var sectionj = getSection(j);
        var toolj = sectionj.getTool();
        if (tooli.number == toolj.number) {
          if (spatialFormat.areDifferent(tooli.diameter, toolj.diameter) ||
              spatialFormat.areDifferent(tooli.cornerRadius, toolj.cornerRadius) ||
              abcFormat.areDifferent(tooli.taperAngle, toolj.taperAngle) ||
              (tooli.numberOfFlutes != toolj.numberOfFlutes)) {
            error(
              subst(
                localize("Using the same tool number for different cutter geometry for operation '%1' and '%2'."),
                sectioni.hasParameter("operation-comment") ? sectioni.getParameter("operation-comment") : ("#" + (i + 1)),
                sectionj.hasParameter("operation-comment") ? sectionj.getParameter("operation-comment") : ("#" + (j + 1))
              )
            );
            return;
          }
        }
      }
    }
  }

  // support program looping for bar work
  if (getProperty("looping")) {
    if (getProperty("numberOfRepeats") < 1) {
      error(localize("numberOfRepeats must be greater than 0."));
      return;
    }
    if (sequenceNumber == 1) {
      sequenceNumber++;
    }
    writeln("");
    writeln("");
    writeComment(localize("Local Looping"));
    writeln("");
    writeBlock(mFormat.format(98), "Q1", "L" + getProperty("numberOfRepeats"));
    onCommand(COMMAND_OPEN_DOOR);
    writeBlock(mFormat.format(30));
    writeln("");
    writeln("");
    writeln("N1 (START MAIN PROGRAM)");
  }

  writeBlock(gPlaneModal.format(18), gFormat.format(40), gCycleModal.format(80), gFeedModeModal.format(99));
  goHome();

  onCommand(COMMAND_CLOSE_DOOR);

  // automatically eject part at end of program
  if (getProperty("autoEject")) {
    ejectRoutine = true;
  }

  // determine starting spindle
  switch (getSection(0).spindle) {
  case SPINDLE_PRIMARY: // main spindle
    activeSpindle = SPINDLE_MAIN;
    machineState.mainChuckIsClamped = true;
    break;
  case SPINDLE_SECONDARY: // sub spindle
    activeSpindle = SPINDLE_SUB;
    machineState.subChuckIsClamped = true;
    break;
  }
}

function onComment(message) {
  writeComment(message);
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
  previousDPMFeed = 0;
  feedOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

function forceModals() {
  if (arguments.length == 0) { // reset all modal variables listed below
    if (typeof gMotionModal != "undefined") {
      gMotionModal.reset();
    }
    if (typeof gPlaneModal != "undefined") {
      gPlaneModal.reset();
    }
    if (typeof gAbsIncModal != "undefined") {
      gAbsIncModal.reset();
    }
    if (typeof gFeedModeModal != "undefined") {
      gFeedModeModal.reset();
    }
  } else {
    for (var i in arguments) {
      arguments[i].reset(); // only reset the modal variable passed to this function
    }
  }
}

function forceUnlockMultiAxis() {
  cAxisBrakeModal.reset();
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  this.feed = feed;
}

function formatFeedMode(mode, isTapping) {
  var fMode = (mode == FEED_PER_REVOLUTION || isTapping) ? getCode("FEED_MODE_UNIT_REV") : getCode("FEED_MODE_UNIT_MIN");
  if (fMode) {
    if (mode == FEED_PER_REVOLUTION || isTapping) {
      feedFormat = fprFormat;
    } else {
      feedFormat = fpmFormat;
    }
    feedOutput = createVariable({prefix:"F"}, feedFormat);
  }
  return gFeedModeModal.format(fMode);
}

function getFeed(f) {
  if (currentSection.feedMode != FEED_PER_REVOLUTION && machineState.feedPerRevolution) {
    f /= spindleSpeed;
  }
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!feedFormat.areDifferent(feedContext.feed, f)) {
        if (feedContext.id == currentFeedId) {
          return ""; // nothing has changed
        }
        forceFeed();
        currentFeedId = feedContext.id;
        return "F#" + (firstFeedParameter + feedContext.id);
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  return feedOutput.format(f); // use feed value
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();
  var feedPerRev = currentSection.feedMode == FEED_PER_REVOLUTION;

  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      if (!hasParameter("operation:tool_feedTransition")) {
        activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      }
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }

  if (hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var finishFeedrateRel;
      if (hasParameter("operation:finishFeedrateRel")) {
        finishFeedrateRel = getParameter("operation:finishFeedrateRel");
      } else if (hasParameter("operation:finishFeedratePerRevolution")) {
        finishFeedrateRel = getParameter("operation:finishFeedratePerRevolution");
      }
      var feedContext = new FeedContext(id, localize("Finish"), feedPerRev ? finishFeedrateRel : getParameter("operation:finishFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), feedPerRev ? getParameter("operation:tool_feedEntryRel") : getParameter("operation:tool_feedEntry"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), feedPerRev ? getParameter("operation:tool_feedExitRel") : getParameter("operation:tool_feedExit"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), feedPerRev ? getParameter("operation:noEngagementFeedrateRel") : getParameter("operation:noEngagementFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting") &&
             hasParameter("operation:tool_feedEntry") &&
             hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(
        id,
        localize("Direct"),
        Math.max(
          feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"),
          feedPerRev ? getParameter("operation:tool_feedEntryRel") : getParameter("operation:tool_feedEntry"),
          feedPerRev ? getParameter("operation:tool_feedExitRel") : getParameter("operation:tool_feedExit")
        )
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), feedPerRev ? getParameter("operation:reducedFeedrateRel") : getParameter("operation:reducedFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), feedPerRev ? getParameter("operation:tool_feedRampRel") : getParameter("operation:tool_feedRamp"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedPlunge")) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(id, localize("Plunge"), feedPerRev ? getParameter("operation:tool_feedPlungeRel") : getParameter("operation:tool_feedPlunge"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }
  if (true) { // high feed
    if (movements & (1 << MOVEMENT_HIGH_FEED)) {
      var feedContext = new FeedContext(id, localize("High Feed"), this.highFeedrate);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedTransition")) {
    if (movements & (1 << MOVEMENT_LINK_TRANSITION)) {
      var feedContext = new FeedContext(id, localize("Transition"), getParameter("operation:tool_feedTransition"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
    }
    ++id;
  }

  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("#" + (firstFeedParameter + feedContext.id) + "=" + feedFormat.format(feedContext.feed), formatComment(feedContext.description));
  }
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function setWorkPlane(abc) {
  // milling only

  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }

  if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z))) {
    return; // no change
  }

  onCommand(COMMAND_UNLOCK_MULTI_AXIS);

  writeBlock(
    gMotionModal.format(0),
    conditional(machineConfiguration.isMachineCoordinate(0), aOutput.format(abc.x)),
    conditional(machineConfiguration.isMachineCoordinate(1), bOutput.format(abc.y)),
    conditional(machineConfiguration.isMachineCoordinate(2), cOutput.format(abc.z))
  );

  onCommand(COMMAND_LOCK_MULTI_AXIS);

  currentWorkPlaneABC = abc;
}

function getBestABC(section) {
  // try workplane orientation
  var abc = section.getABCByPreference(machineConfiguration, section.workPlane, getCurrentDirection(), C, PREFER_CLOSEST, ENABLE_ALL);
  if (section.doesToolpathFitWithinLimits(machineConfiguration, abc)) {
    return abc;
  }
  var currentABC = new Vector(abc);

  // quadrant boundaries are the preferred solution
  var quadrants = [0, 90, 180, 270];
  for (var i = 0; i < quadrants.length; ++i) {
    abc.setZ(toRad(quadrants[i]));
    if (section.doesToolpathFitWithinLimits(machineConfiguration, abc)) {
      abc = machineConfiguration.remapToABC(abc, currentABC);
      abc = machineConfiguration.remapABC(abc);
      return abc;
    }
  }

  // attempt to find soultion at fixed angle rotations
  var maxTries = 60; // every 6 degrees
  var delta = (Math.PI * 2) / maxTries;
  var angle = delta;
  for (var i = 0; i < (maxTries - 1); i++) {
    abc.setZ(angle);
    if (section.doesToolpathFitWithinLimits(machineConfiguration, abc)) {
      abc = machineConfiguration.remapToABC(abc, currentABC);
      abc = machineConfiguration.remapABC(abc);
      return abc;
    }
    angle += delta;
  }
  return abc;
}

function getWorkPlaneMachineABC(section, workPlane) {
  var W = workPlane; // map to global frame
  var abc;
  if (machineState.isTurningOperation && gotBAxis) {
    var both = machineConfiguration.getABCByDirectionBoth(workPlane.forward);
    abc = both[0];
    if (both[0].z != 0) {
      abc = both[1];
    }
  } else {
    abc = bestABC ? bestABC :
      section.getABCByPreference(machineConfiguration, W, getCurrentDirection(), C, PREFER_CLOSEST, ENABLE_RESET);
  }

  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize("Orientation not supported."));
    return abc;
  }

  if (machineState.isTurningOperation && gotBAxis && !bAxisIsManual) { // remapABC can change the B-axis orientation
    if (abc.z != 0) {
      error(localize("Could not calculate a B-axis turning angle within the range of the machine."));
      return abc;
    }
  }

  var tcp = false;
  if (tcp) { // do not go into if turning
    setRotation(W); // TCP mode
  } else {
    var O = machineConfiguration.getOrientation(abc);
    var R = machineConfiguration.getRemainingOrientation(abc, W);
    setRotation(R);
  }
  return abc;
}

function getBAxisOrientationTurning(section) {
  // THIS CODE IS NOT TESTED.
  var toolAngle = hasParameter("operation:tool_angle") ? getParameter("operation:tool_angle") : 0;
  var toolOrientation = section.toolOrientation;
  if (toolAngle && toolOrientation != 0) {
    error(localize("You cannot use tool angle and tool orientation together in operation " + "\"" + (getParameter("operation-comment")) + "\""));
  }

  var angle = toRad(toolAngle) + toolOrientation;

  var axis = new Vector(0, 1, 0);
  var mappedAngle;
  if (bAxisIsManual) {
    mappedAngle = 0; // manual b-axis used for milling only
  } else {
    mappedAngle = (currentSection.spindle == SPINDLE_PRIMARY ? (Math.PI / 2 - angle) : (Math.PI / 2 - angle));
  }
  var mappedWorkplane = new Matrix(axis, mappedAngle);
  var abc = getWorkPlaneMachineABC(section, mappedWorkplane);
  return abc;
}

function getSpindle(whichSpindle) {
  // safety conditions
  if (getNumberOfSections() == 0) {
    return SPINDLE_MAIN;
  }
  if (getCurrentSectionId() < 0) {
    if (machineState.liveToolIsActive && (whichSpindle == TOOL)) {
      return SPINDLE_LIVE;
    } else {
      return getSection(getNumberOfSections() - 1).spindle;
    }
  }

  // Turning is active or calling routine requested which spindle part is loaded into
  if (machineState.isTurningOperation || machineState.axialCenterDrilling || (whichSpindle == PART)) {
    return currentSection.spindle;
  //Milling is active
  } else {
    return SPINDLE_LIVE;
  }
}

function getSecondarySpindle() {
  var spindle = getSpindle(PART);
  return (spindle == SPINDLE_MAIN) ? SPINDLE_SUB : SPINDLE_MAIN;
}

function getSpindleAxis() {
  if (getSpindle(TOOL) != SPINDLE_LIVE) {
    return POSX;
  }
  if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
    return POSZ;
  } else if (isPerpto(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
    return POSX;
  } else {
    error(localize("Work plane must be Positive-X or Positive-Z."));
    return -1;
  }
}

/** Invert YZC axes for the sub-spindle. */
function invertAxes(activate, polarMode) {
  var scaleValue = reverseAxes ? -1 : 1;
  var yAxisPrefix = polarMode ? "C" : "Y";
  var yIsEnabled = yOutput.isEnabled();
  yFormat.setScale(activate ? scaleValue : 1);
  zFormat.setScale(activate ? -1 : 1);
  cFormat.setScale(DEG * (activate ? scaleValue : 1));

  yOutput = createVariable({onchange:function() {yAxisIsRetracted = false;}, prefix:yAxisPrefix}, yFormat);
  zOutput = createVariable({prefix:"Z"}, zFormat);
  if (polarMode) {
    cOutput.disable();
  } else {
    cOutput = createVariable({prefix:"C"}, cFormat);
    if (!yIsEnabled) {
      yOutput.disable();
    }
  }
  jOutput = createReferenceVariable({prefix:"J", force:true}, yFormat);
  kOutput = createReferenceVariable({prefix:"K", force:true}, zFormat);
}

/** determines if the axes in the given plane are mirrored */
function isMirrored(plane) {
  plane = plane == -1 ? getCompensationPlane(getCurrentDirection(), false, false) : plane;
  switch (plane) {
  case PLANE_XY:
    if ((xFormat.getScale() * yFormat.getScale()) < 0) {
      return true;
    }
    break;
  case PLANE_YZ:
    if ((yFormat.getScale() * zFormat.getScale()) < 0) {
      return true;
    }
    break;
  case PLANE_ZX:
    if ((zFormat.getScale() * xFormat.getScale()) < 0) {
      return true;
    }
    break;
  }
  return false;
}

function isPerpto(a, b) {
  return Math.abs(Vector.dot(a, b)) < (1e-7);
}

function setSpindleOrientationTurning(section) {
  var J; // cutter orientation
  var R; // cutting quadrant
  var leftHandTool = (hasParameter("operation:tool_hand") && (getParameter("operation:tool_hand") == "L" || getParameter("operation:tool_holderType") == 0));
  if (hasParameter("operation:machineInside")) {
    if (getParameter("operation:machineInside") == 0) {
      R = (currentSection.spindle == SPINDLE_PRIMARY) ? 3 : 4;
    } else {
      R = (currentSection.spindle == SPINDLE_PRIMARY) ? 2 : 1;
    }
  } else {
    if ((hasParameter("operation-strategy") && getParameter("operation-strategy") == "turningFace") ||
      (hasParameter("operation-strategy") && getParameter("operation-strategy") == "turningPart")) {
      R = (currentSection.spindle == SPINDLE_PRIMARY) ? 3 : 4;
    } else {
      error(subst(localize("Failed to identify spindle orientation for operation \"%1\"."), getOperationComment()));
      return;
    }
  }
  if (leftHandTool) {
    J = (currentSection.spindle == SPINDLE_PRIMARY) ? 2 : 1;
  } else {
    J = (currentSection.spindle == SPINDLE_PRIMARY) ? 1 : 2;
  }
  writeComment("Post processor is not customized, add code for cutter orientation and cutting quadrant here if needed.");
}

function onSectionSpecialCycle() {
  if (!isFirstSection()) {
    activateMachine(currentSection);
  }
}

var bAxisOrientationTurning = new Vector(0, 0, 0);
function onSection() {
  // Detect machine configuration
  var currentTurret = isFirstSection() ? activeTurret : activateMachine(currentSection);

  // invert axes for secondary spindle
  if (getSpindle(PART) == SPINDLE_SUB) {
    invertAxes(true, false); // polar mode has not been enabled yet
  }

  // Define Machining modes
  tapping = isTappingCycle();

  var forceSectionRestart = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();

  machineState.isTurningOperation = (currentSection.getType() == TYPE_TURNING);
  if (machineState.isTurningOperation && gotBAxis) {
    bAxisOrientationTurning = getBAxisOrientationTurning(currentSection);
  }

  var insertToolCall = isToolChangeNeeded("number", "compensationOffset", "diameterOffset", "lengthOffset", "productId") ||
  forceSectionRestart;

  var retracted = false; // specifies that the tool has been retracted to the safe plane

  var newWorkOffset = isFirstSection() || forceSectionRestart ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() || forceSectionRestart ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (machineState.isTurningOperation &&
      abcFormat.areDifferent(bAxisOrientationTurning.x, machineState.currentBAxisOrientationTurning.x) ||
      abcFormat.areDifferent(bAxisOrientationTurning.y, machineState.currentBAxisOrientationTurning.y) ||
      abcFormat.areDifferent(bAxisOrientationTurning.z, machineState.currentBAxisOrientationTurning.z));

  partCutoff = getParameter("operation-strategy", "") == "turningPart";

  var yAxisWasEnabled = !machineState.usePolarCoordinates && !machineState.usePolarInterpolation && machineState.liveToolIsActive;
  updateMachiningMode(currentSection); // sets the needed machining mode to machineState (usePolarInterpolation, usePolarCoordinates, axialCenterDrilling)

  // Get the active spindle
  var newSpindle = true;
  var tempSpindle = getSpindle(TOOL);
  var tempPartSpindle = getSpindle(PART);
  if (isFirstSection()) {
    previousSpindle = tempSpindle;
    previousPartSpindle = currentSection.spindle;
  }
  newSpindle = tempSpindle != previousSpindle;

  // End the previous section if a new tool is selected
  if (!isFirstSection() && insertToolCall &&
      !(machineState.stockTransferIsActive && partCutoff)) {
    if (machineState.stockTransferIsActive) {
      writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_OFF", getSpindle(PART))));
      /*pOutput.format(getCode("SELECT_SPINDLE", SPINDLE_MAIN))*/
    } else {
      if (previousSpindle == SPINDLE_LIVE) {
        onCommand(COMMAND_STOP_SPINDLE);
        forceUnlockMultiAxis();
        //onCommand(COMMAND_UNLOCK_MULTI_AXIS);
        writeBlock(cAxisBrakeModal.format(getCode("UNLOCK_MULTI_AXIS", previousPartSpindle)));
        if (gotSecondarySpindle && previousPartSpindle == SPINDLE_SUB) {
          writeBlock(gFormat.format(111), formatComment("Cross Axis Control cancel"));
        }
        if ((tempSpindle != SPINDLE_LIVE) && !getProperty("optimizeCAxisSelect")) {
          cAxisEngageModal.reset();
          writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", previousPartSpindle)));
        }
      }
      onCommand(COMMAND_COOLANT_OFF);
    }
    goHome();
    // mInterferModal.reset();
    // writeBlock(mInterferModal.format(getCode("INTERFERENCE_CHECK_OFF", getSpindle(PART))));
    if (getProperty("optionalStop")) {
      onCommand(COMMAND_OPTIONAL_STOP);
      gMotionModal.reset();
    }
  }
  // Consider part cutoff as stockTransfer operation
  if (!(machineState.stockTransferIsActive && partCutoff)) {
    machineState.stockTransferIsActive = false;
  }

  // Process Pass Through commands
  executeManualNC();

  // Output the operation description
  writeln("");
  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      if (insertToolCall && getProperty("showSequenceNumbers") == "toolChange") {
        writeCommentSeqno(comment);
      } else {
        writeComment(comment);
      }
    }
  }

  // Position all axes at home
  if (insertToolCall && !machineState.stockTransferIsActive) {
    /*if (gotSecondarySpindle) {
      if (currentSection.spindle == SPINDLE_SECONDARY && !currentSection.spindle == SPINDLE_PRIMARY){
        writeBlock(gMotionModal.format(0), gFormat.format(53), barOutput.format(0), "(ENSURE SUB HOME BEFORE SUB OPS)" ); // retract Sub Spindle if applicable
      }
    }*/
    goHome();

    // Stop the spindle
    if (newSpindle) {
      onCommand(COMMAND_STOP_SPINDLE);
    }
  }

  // Select the active spindle
  if (insertToolCall) {
    gSelectSpindleModal.reset();
  }
  if (gotSecondarySpindle) {
    writeBlock(gSelectSpindleModal.format(getCode("ACTIVATE_SPINDLE", getSpindle(PART))));
  }

  // wcs
  if (insertToolCall) { // force work offset when changing tool
    currentWorkOffset = undefined;
    forceModals();
  }

  var wcsOut = "";
  if (currentSection.workOffset != currentWorkOffset) {
    forceWorkPlane();
    wcsOut = currentSection.wcs;
    currentWorkOffset = currentSection.workOffset;
  }

  var feedMode = formatFeedMode(currentSection.feedMode, tapping);

  var plane = 18;
  // Live Spindle is active
  if (tempSpindle == SPINDLE_LIVE) {
    writeBlock(cAxisEngageModal.format(getCode("ENABLE_C_AXIS", getSpindle(PART))));
    switch (getMachiningDirection(currentSection)) {
    case MACHINING_DIRECTION_AXIAL:
      plane = getG17Code();
      break;
    case MACHINING_DIRECTION_RADIAL:
      plane = 19;
      break;
    case MACHINING_DIRECTION_INDEXING:
      plane = getG17Code();
      break;
    default:
      error(subst(localize("Unsupported machining direction for operation " + "\"" + "%1" + "\"" + "."), getOperationComment()));
      return;
    }
    if (insertToolCall || wcsOut) {
      forceUnlockMultiAxis();
      //onCommand(COMMAND_UNLOCK_MULTI_AXIS);
      if (!getProperty("optimizeCAxisSelect")) {
        cAxisEngageModal.reset();
      }
      if (getProperty("isoModeOrMazatrol") == "ISO") {
        writeBlock(wcsOut/*, mFormat.format(getCode("SET_SPINDLE_FRAME", getSpindle(PART)))*/);
      } else {
        if (currentSection.spindle == SPINDLE_SECONDARY) {
          writeBlock("G53.5 Z#150");
        } else {
          writeBlock("G53.5");
        }
      }
      if (currentSection.spindle == SPINDLE_SECONDARY) {
        writeBlock(gFormat.format(110), "C2", formatComment("Cross Axis Control"));
      }
      writeBlock(gMotionModal.format(0), gFormat.format(getProperty("controllerType") == "640MT" ? 28 : 53), "H" + abcFormat.format(0)); // unwind c-axis
      if (!machineState.usePolarInterpolation && !machineState.usePolarCoordinates && !currentSection.isMultiAxis()) {
        //onCommand(COMMAND_LOCK_MULTI_AXIS);
      }
    } else {
      if (machineState.usePolarInterpolation || machineState.usePolarCoordinates || currentSection.isMultiAxis()) {
        onCommand(COMMAND_UNLOCK_MULTI_AXIS);
      }
    }
    // Turning is active
  } else {
    if (insertToolCall || wcsOut) {
      cAxisEngageModal.reset();
      writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(PART))));
      if (getProperty("isoModeOrMazatrol") == "ISO") {
        writeBlock(gMotionModal.format(0), wcsOut);
      } else {
        if (currentSection.spindle == SPINDLE_SECONDARY) {
          writeBlock("G53.5 Z#150");
        } else {
          writeBlock("G53.5");
        }
      }
      if (!getProperty("optimizeCAxisSelect")) {
        cAxisEngageModal.reset();
      }
    }
  }

  // Output modal commands here
  writeBlock(feedMode, gPlaneModal.format(plane));

  // Write out notes
  if (getProperty("showNotes") && hasParameter("notes")) {
    var notes = getParameter("notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }

  switch (getMachiningDirection(currentSection)) {
  case MACHINING_DIRECTION_AXIAL:
    // writeBlock(gPlaneModal.format(getG17Code()));
    break;
  case MACHINING_DIRECTION_RADIAL:
    if (gotBAxis) {
      // writeBlock(gPlaneModal.format(getG17Code()));
    } else {
      // writeBlock(gPlaneModal.format(getG17Code())); // RADIAL
    }
    break;
  case MACHINING_DIRECTION_INDEXING:
    // writeBlock(gPlaneModal.format(getG17Code())); // INDEXING
    break;
  default:
    error(subst(localize("Unsupported machining direction for operation " +  "\"" + "%1" + "\"" + "."), getOperationComment()));
    return;
  }

  var abc;
  if (machineConfiguration.isMultiAxisConfiguration()) {
    if (machineState.isTurningOperation) {
      if (gotBAxis) {
        cancelTransformation();
        // handle B-axis support for turning operations here
        abc = bAxisOrientationTurning;
        //setSpindleOrientationTurning();
      } else {
        abc = getWorkPlaneMachineABC(currentSection, currentSection.workPlane);
      }
    } else {
      if (currentSection.isMultiAxis()) {
        forceWorkPlane();
        cancelTransformation();
        onCommand(COMMAND_UNLOCK_MULTI_AXIS);
        abc = currentSection.getInitialToolAxisABC();
      } else {
        abc = getWorkPlaneMachineABC(currentSection, currentSection.workPlane);
      }
    }
  } else { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported by the CNC machine."));
      return;
    }
    setRotation(remaining);
  }

  if (insertToolCall) {
    forceWorkPlane();
    cAxisEngageModal.reset();
    retracted = true;
    onCommand(COMMAND_COOLANT_OFF);

    var compensationOffset = tool.isTurningTool() ? tool.compensationOffset : tool.lengthOffset;
    if (compensationOffset > 99) {
      error(localize("Compensation offset is out of range."));
      return;
    }

    if (tool.number > getProperty("maxTool")) {
      warning(localize("Tool number exceeds maximum value."));
    }

    if (tool.number == 0) {
      error(localize("Tool number cannot be 0"));
      return;
    }

    writeBlock("T" + toolFormat.format(tool.number * 100 + compensationOffset)
    + conditional(tool.productId, "." + tool.productId));
    if (tool.comment) {
      writeComment(tool.comment);
    }

    // Write out maximum spindle speed
    if (insertToolCall) {
      if ((tool.maximumSpindleSpeed > 0) && (currentSection.getTool().getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED)) {
        var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, getProperty("maximumSpindleSpeed")) : getProperty("maximumSpindleSpeed");
        writeBlock(gFormat.format(50),
          sOutput.format(maximumSpindleSpeed),
          conditional(getProperty("controllerType") != "640MT", rcssOutput.format(getCode("SELECT_SPINDLE", getSpindle(PART))))
        );
        sOutput.reset();
      }
    }

    // Engage tailstock
    if (getProperty("useTailStock")) {
      if (machineState.axialCenterDrilling || (currentSection.spindle == SPINDLE_SECONDARY) ||
       (machineState.liveToolIsActive && (getMachiningDirection(currentSection) == MACHINING_DIRECTION_AXIAL))) {
        if (currentSection.tailstock) {
          warning(localize("Tail stock is not supported for secondary spindle or Z-axis milling."));
        }
        if (machineState.tailstockIsActive) {
          writeBlock(getCode("TAILSTOCK_OFF"));
          writeBlock(mFormat.format(32), formatComment("RETURN TAILSTOCK TO HOME POSITION"));
        }
      } else {
        writeBlock(currentSection.tailstock ? getCode("TAILSTOCK_ON") : getCode("TAILSTOCK_OFF"));
        if (!machineState.tailstockIsActive) {
          writeBlock(mFormat.format(32), formatComment("RETURN TAILSTOCK TO HOME POSITION"));
        }
      }
    }
  }

  // Activate part catcher for part cutoff section
  if (getProperty("usePartCatcher") && partCutoff && currentSection.partCatcher) {
    engagePartCatcher(true);
  }

  // command stop for manual tool change, useful for quick change live tools
  if (insertToolCall && tool.manualToolChange) {
    onCommand(COMMAND_STOP);
    writeBlock("(" + "MANUAL TOOL CHANGE TO T" + toolFormat.format(tool.number * 100 + compensationOffset) + ")");
  }

  // Output spindle codes
  if (newSpindle) {
    // select spindle if required
  }

  var forceRPMMode = false;
  var spindleChanged = tool.type != TOOL_PROBE &&
    (insertToolCall || forceSpindleSpeed || isSpindleSpeedDifferent() || newSpindle);
  if (spindleChanged) {
    forceSpindleSpeed = false;
    if (machineState.isTurningOperation) {
      if (spindleSpeed > getProperty("maximumSpindleSpeed")) {
        warning(subst(localize("Spindle speed exceeds maximum value for operation \"%1\"."), getOperationComment()));
      }
    } else {
      if (spindleSpeed > maximumSpindleSpeedLive) {
        warning(subst(localize("Spindle speed exceeds maximum value for operation \"%1\"."), getOperationComment()));
      }
    }
    // Turn spindle on
    forceRPMMode = (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED);
    startSpindle(false, forceRPMMode, getFramePosition(currentSection.getInitialPosition()));
  }

  // Turn off interference checking with secondary spindle
  // if (getSpindle(PART) == SPINDLE_SUB) {
  // writeBlock(mInterferModal.format(getCode("INTERFERENCE_CHECK_OFF", getSpindle(PART))));
  // }

  forceAny();
  gMotionModal.reset();

  if (currentSection.isMultiAxis()) {
    writeBlock(gMotionModal.format(0), aOutput.format(abc.x), bOutput.format(abc.y), cOutput.format(abc.z));
    forceWorkPlane();
    cancelTransformation();
  } else {
    if (machineState.isTurningOperation || machineState.axialCenterDrilling) {
      if (gotBAxis) {
        bOutput.reset();
        writeBlock(gMotionModal.format(0), bOutput.format(getB(abc, currentSection)));
        machineState.currentBAxisOrientationTurning = abc;
      }
    } else if (!machineState.usePolarCoordinates && !machineState.usePolarInterpolation) {
      setWorkPlane(abc);
    }
  }

  // enable Polar coordinates mode
  if (machineState.usePolarCoordinates && (tool.type != TOOL_PROBE)) {
    if (polarCoordinatesDirection == undefined) {
      error(localize("Polar coordinates axis direction to maintain must be defined as a vector - x,y,z."));
      return;
    }
    setPolarCoordinates(true);
  }

  if (abc !== undefined) {
    cOutput.format(abc.z); // make C current - we do not want to output here
  }

  var initialPosition = getFramePosition(currentSection.getInitialPosition());

  if (insertToolCall || retracted || (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED)) {
    gMotionModal.reset();
    setCoolant(tool.coolant);
    if (machineState.usePolarCoordinates) {
      writeBlock(gPlaneModal.format(getG17Code()));
      var polarPosition = getPolarPosition(initialPosition.x, initialPosition.y, initialPosition.z);
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
      writeBlock(
        gMotionModal.format(0),
        xOutput.format(polarPosition.first.x),
        conditional(gotYAxis, yOutput.format(polarPosition.first.y)),
        cOutput.format(polarPosition.second.z)
      );
    } else if (machineState.usePolarInterpolation) {
      setPolarCoordinates(true);
      var polarPosition = getPolarPosition(initialPosition.x, initialPosition.y, initialPosition.z);
      setPolarCoordinates(false);
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
      writeBlock(
        gMotionModal.format(0),
        xOutput.format(polarPosition.first.x),
        conditional(gotYAxis, yOutput.format(polarPosition.first.y))
      );
    } else {
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
      writeBlock(gMotionModal.format(0), xOutput.format(initialPosition.x),
        conditional(turret1GotYAxis, yOutput.format(initialPosition.y)));
    }
  } else if ((machineState.usePolarCoordinates || machineState.usePolarInterpolation) && yAxisWasEnabled) {
    if (turret1GotYAxis && yOutput.isEnabled()) {
      writeBlock(gMotionModal.format(0), yOutput.format(0));
    }
  }

  // enable SFM spindle speed
  if (forceRPMMode) {
    startSpindle(false, false);
  }

  if (machineState.usePolarInterpolation) {
    setPolarInterpolation(true); // enable polar interpolation mode
  }
  if (getProperty("useParametricFeed") && !isDrillingCycle(true)) {
    if (!insertToolCall &&
        activeMovements &&
        (getCurrentSectionId() > 0) &&
        ((getPreviousSection().getPatternId() == currentSection.getPatternId()) && (currentSection.getPatternId() != 0))) {
      // use the current feeds
    } else {
      initializeActiveFeeds();
    }
  } else {
    activeMovements = undefined;
  }

  previousSpindle = tempSpindle;
  previousPartSpindle = tempPartSpindle;
  activeSpindle = tempSpindle;

  if (false) { // DEBUG
    for (var key in machineState) {
      writeComment(key + " : " + machineState[key]);
    }
    writeComment("Machining direction = " + getMachiningDirection(currentSection));
    writeComment("Tapping = " + tapping);
    // writeln("(" + (getMachineConfigurationAsText(machineConfiguration)) + ")");
  }
}

var MACHINING_DIRECTION_AXIAL = 0;
var MACHINING_DIRECTION_RADIAL = 1;
var MACHINING_DIRECTION_INDEXING = 2;

function getMachiningDirection(section) {
  var forward = section.isMultiAxis() ? section.getGlobalInitialToolAxis() : section.workPlane.forward;
  if (isSameDirection(forward, new Vector(0, 0, 1))) {
    return MACHINING_DIRECTION_AXIAL;
  } else if (Vector.dot(forward, new Vector(0, 0, 1)) < 1e-7) {
    return MACHINING_DIRECTION_RADIAL;
  } else {
    return MACHINING_DIRECTION_INDEXING;
  }
}

function updateMachiningMode(section) {
  machineState.axialCenterDrilling = false; // reset
  machineState.usePolarInterpolation = false; // reset
  machineState.usePolarCoordinates = false; // reset

  if ((section.getType() == TYPE_MILLING) && !section.isMultiAxis()) {
    if (getMachiningDirection(section) == MACHINING_DIRECTION_AXIAL) {
      if (isDrillingCycle(section, false)) {
        // drilling axial
        machineState.axialCenterDrilling = isAxialCenterDrilling(section, true);
        if (!machineState.axialCenterDrilling && !isAxialCenterDrilling(section, false)) { // several holes not on XY center
          // bestABC = section.getABCByPreference(machineConfiguration, section.workPlane, getCurrentDirection(), C, PREFER_CLOSEST, ENABLE_RESET | ENABLE_LIMITS);
          bestABC = getBestABC(section);
          bestABC = section.doesToolpathFitWithinLimits(machineConfiguration, bestABC) ? bestABC : undefined;
          if (!getProperty("useYAxisForDrilling") || bestABC == undefined) {
            machineState.usePolarCoordinates = true;
          }
        }
      } else { // milling
        if (gotPolarInterpolation && forcePolarInterpolation) { // polar mode is requested by user
          machineState.usePolarInterpolation = true;
          bestABC = undefined;
        } else if (forcePolarCoordinates) { // Polar coordinate mode is requested by user
          machineState.usePolarCoordinates = true;
          bestABC = undefined;
        } else {
          //bestABC = section.getABCByPreference(machineConfiguration, section.workPlane, getCurrentDirection(), C, PREFER_CLOSEST, ENABLE_RESET | ENABLE_LIMITS);
          bestABC = getBestABC(section);
          bestABC = section.doesToolpathFitWithinLimits(machineConfiguration, bestABC) ? bestABC : undefined;
          if (bestABC == undefined) { // toolpath does not match XY ranges, enable interpolation mode
            if (gotPolarInterpolation) {
              machineState.usePolarInterpolation = true;
            } else {
              machineState.usePolarCoordinates = true;
            }
          }
        }
      }
    } else if (getMachiningDirection(section) == MACHINING_DIRECTION_RADIAL) { // G19 plane
      var range = section.getOptimizedBoundingBox(machineConfiguration, machineConfiguration.getABC(section.workPlane));
      var yAxisWithinLimits = machineConfiguration.getAxisY().getRange().isWithin(yFormat.getResultingValue(range.lower.y)) &&
        machineConfiguration.getAxisY().getRange().isWithin(yFormat.getResultingValue(range.upper.y));
      if (!gotYAxis) {
        if (!section.isMultiAxis() && !yAxisWithinLimits) {
          error(subst(localize("Y-axis motion is not possible without a Y-axis for operation \"%1\"."), getOperationComment()));
          return;
        }
      } else {
        if (!yAxisWithinLimits) {
          error(subst(localize("Toolpath exceeds the maximum ranges for operation \"%1\"."), getOperationComment()));
          return;
        }
      }
      // C-coordinates come from setWorkPlane or is within a multi axis operation, we cannot use the C-axis for non wrapped toolpathes (only multiaxis works, all others have to be into XY range)
    } else {
      // usePolarCoordinates & usePolarInterpolation is only supported for axial machining, keep false
    }
  } else {
    // turning or multi axis, keep false
  }

  if (machineState.axialCenterDrilling) {
    cOutput.disable();
  } else {
    cOutput.enable();
  }

  var checksum = 0;
  checksum += machineState.usePolarInterpolation ? 1 : 0;
  checksum += machineState.usePolarCoordinates ? 1 : 0;
  checksum += machineState.axialCenterDrilling ? 1 : 0;
  validate(checksum <= 1, localize("Internal post processor error."));
}

function getOperationComment() {
  var operationComment = hasParameter("operation-comment") && getParameter("operation-comment");
  return operationComment;
}

function setPolarInterpolation(activate) {
  if (activate) {
    cOutput.enable();
    cOutput.reset();
    writeBlock(gMotionModal.format(0), cOutput.format(0)); // set C-axis to 0 to avoid G112 issues
    writeBlock(gFormat.format(17), "UH");
    writeBlock(gPolarModal.format(getCode("POLAR_INTERPOLATION_ON", getSpindle(PART)))); // command for polar interpolation
    writeBlock(gPlaneModal.format(getG17Code()));
    yOutput = createVariable({prefix:"C"}, yFormat);
    yOutput.enable(); // required for G12.1
    cOutput.disable();
  } else {
    writeBlock(gPolarModal.format(getCode("POLAR_INTERPOLATION_OFF", getSpindle(PART))));
    yOutput = createVariable({prefix:"Y"}, yFormat);
    if (!turret1GotYAxis) {
      yOutput.disable();
    }
    cOutput.enable();
  }
}

function goHome() {
  var yAxis = "";
  if (turret1GotYAxis) {
    yAxis = getProperty("controllerType") == "640MT" ? "V" + xFormat.format(0) : "Y" + yFormat.format(0);
  }
  if (getProperty("controllerType") == "640MT") {
    writeBlock(gMotionModal.format(0), gFormat.format(28), "U" + xFormat.format(0), yAxis);
    if (getProperty("useG53Zhome")) {
      writeBlock(gMotionModal.format(0), gFormat.format(28), "W" + zFormat.format(0));
    }
  } else {
    writeBlock(gMotionModal.format(0), gFormat.format(53), "X" + xFormat.format(0), yAxis);
    if (getProperty("useG53Zhome")) {
      writeBlock(gMotionModal.format(0), gFormat.format(53), "Z" + zFormat.format(0));
    }
  }
  if (!getProperty("useG53Zhome")) {
    gMotionModal.reset();
    zOutput.reset();
    writeBlock(gMotionModal.format(0), zOutput.format(getProperty("homePositionZ")));
  }
}

function onDwell(seconds) {
  if (seconds > 99999.999) {
    warning(localize("Dwelling time is out of range."));
  }
  writeBlock(gFeedModeModal.format(98), gFormat.format(4), dwellFormat.format(seconds));
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

function getCompensationPlane(abc, returnCode, outputPlane) {
  var plane;
  if (machineState.isTurningOperation) {
    plane = PLANE_ZX;
  } else if (machineState.usePolarInterpolation) {
    plane = PLANE_XY;
  } else {
    var found = false;
    if (!found) {
      if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
        plane = PLANE_XY;
      } else if (Vector.dot(currentSection.workPlane.forward, new Vector(0, 0, 1)) < 1e-7) {
        plane = PLANE_YZ;
      } else {
        if (returnCode) {
          if (getMachiningDirection(currentSection) == MACHINING_DIRECTION_AXIAL) {
            plane = PLANE_XY;
          } else {
            plane = PLANE_ZX;
          }
        } else {
          plane = -1;
          if (outputPlane) {
            error(localize("Tool orientation is not supported for radius compensation."));
            return -1;
          }
        }
      }
    }
  }
  var code = plane == -1 ? -1 : (plane == PLANE_XY ? getG17Code() : (plane == PLANE_ZX ? 18 : 19));
  if (outputPlane) {
    writeBlock(gPlaneModal.format(code));
  }
  return returnCode ? code : plane;
}

var resetFeed = false;

function getHighfeedrate(radius) {
  if (currentSection.feedMode == FEED_PER_REVOLUTION) {
    if (toDeg(radius) <= 0) {
      radius = toPreciseUnit(0.1, MM);
    }
    var rpm = spindleSpeed; // rev/min
    if (currentSection.getTool().getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
      var O = 2 * Math.PI * radius; // in/rev
      rpm = tool.surfaceSpeed / O; // in/min div in/rev => rev/min
    }
    return highFeedrate / rpm; // in/min div rev/min => in/rev
  }
  return highFeedrate;
}

function onRapid(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    var useG1 = ((((x ? 1 : 0) + (y ? 1 : 0) + (z ? 1 : 0)) > 1) || machineState.usePolarInterpolation) && !isCannedCycle;
    var gCode = useG1 ? 1 : 0;
    var f = useG1 ? (getFeed(machineState.usePolarInterpolation ? toPreciseUnit(1500, MM) : getHighfeedrate(_x))) : "";
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      var plane = getCompensationPlane(getCurrentDirection(), false, true);
      var ccLeft = isMirrored(plane) ? 42 : 41;
      var ccRight = isMirrored(plane) ? 41 : 42;
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(
          gMotionModal.format(gCode),
          gFormat.format(ccLeft),
          x, y, z, f
        );
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(
          gMotionModal.format(gCode),
          gFormat.format(ccRight),
          x, y, z, f
        );
        break;
      default:
        writeBlock(gMotionModal.format(gCode), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gMotionModal.format(gCode), x, y, z, f);
      resetFeed = false;
    }
  }
}

function onLinear(_x, _y, _z, feed) {
  if (isSpeedFeedSynchronizationActive()) {
    resetFeed = true;
    var threadPitch = getParameter("operation:threadPitch");
    var threadsPerInch = 1.0 / threadPitch; // per mm for metric
    writeBlock(gMotionModal.format(32), xOutput.format(_x), yOutput.format(_y), zOutput.format(_z), pitchOutput.format(1 / threadsPerInch));
    return;
  }
  if (resetFeed) {
    resetFeed = false;
    forceFeed();
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      if (machineState.isTurningOperation) {
        writeBlock(gPlaneModal.format(18));
      } else if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
        writeBlock(gPlaneModal.format(getG17Code()));
      } else if (Vector.dot(currentSection.workPlane.forward, new Vector(0, 0, 1)) < 1e-7) {
        writeBlock(gPlaneModal.format(19));
      } else {
        error(localize("Tool orientation is not supported for radius compensation."));
        return;
      }
      var plane = getCompensationPlane(getCurrentDirection(), false, true);
      var ccLeft = isMirrored(plane) ? 42 : 41;
      var ccRight = isMirrored(plane) ? 41 : 42;
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(
          gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1),
          gFormat.format(ccLeft),
          x, y, z, f
        );
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(
          gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1),
          gFormat.format(ccRight),
          x, y, z, f
        );
        break;
      default:
        writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("Multi-axis motion is not supported for Polar coordinate mode."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);
  if (x || y || z || a || b || c) {
    var useG1 = (((x ? 1 : 0) + (y ? 1 : 0) + (z ? 1 : 0)) + (a ? 1 : 0) + (b ? 1 : 0) + (c ? 1 : 0) > 1);
    if (useG1) {
      // axes are not synchronized
      writeBlock(gMotionModal.format(1), x, y, z, a, b, c, getFeed(highFeedrate));
    } else {
      writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
      forceFeed();
    }
  }
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("Multi-axis motion is not supported for Polar coordinate mode."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);

  if (x || y || z || a || b || c) {
    writeBlock(gMotionModal.format(1), x, y, z, a, b, c, getFeed(feed));
  }
}

// Start of Polar coordinates
var polarCoordinatesDirection = new Vector(1, 0, 0); // vector to maintain tool at while in polar interpolation
var polarSpindleAxisSave;
function setPolarCoordinates(mode) {
  if (!mode) { // turn off polar mode if required
    if (isPolarModeActive()) {
      deactivatePolarMode();
      if (gotBAxis) {
        machineConfiguration.setSpindleAxis(polarSpindleAxisSave);
        bOutput.enable();
      }
      // setPolarFeedMode(false);
    }
    return;
  }

  var direction = polarCoordinatesDirection;

  // determine the rotary axis to use for Polar coordinates
  var axis = undefined;
  if (machineConfiguration.getAxisV().isEnabled()) {
    if (Vector.dot(machineConfiguration.getAxisV().getAxis(), currentSection.workPlane.getForward()) != 0) {
      axis = machineConfiguration.getAxisV();
    }
  }
  if (axis == undefined && machineConfiguration.getAxisU().isEnabled()) {
    if (Vector.dot(machineConfiguration.getAxisU().getAxis(), currentSection.workPlane.getForward()) != 0) {
      axis = machineConfiguration.getAxisU();
    }
  }
  if (axis == undefined) {
    error(localize("Polar coordinates require an active rotary axis be defined in direction of workplane normal."));
  }

  // calculate directional vector from initial position
  if (direction == undefined) {
    error(localize("Polar coordinates initiated without a directional vector."));
    return;
  }

  // activate polar coordinates
  // setPolarFeedMode(true); // enable multi-axis feeds for polar mode

  if (gotBAxis) {
    polarSpindleAxisSave = machineConfiguration.getSpindleAxis();
    machineConfiguration.setSpindleAxis(new Vector(0, 0, 1));
    bOutput.disable();
  }
  activatePolarMode(getTolerance() / 2, 0, direction);
  var polarPosition = getPolarPosition(currentSection.getInitialPosition().x, currentSection.getInitialPosition().y, currentSection.getInitialPosition().z);
  setCurrentPositionAndDirection(polarPosition);
  //forceWorkPlane();
}
// End of polar coordinates

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  var directionCode;
  if (isMirrored(getCircularPlane())) {
    directionCode = clockwise ? 3 : 2;
  } else {
    directionCode = clockwise ? 2 : 3;
  }

  if (isSpeedFeedSynchronizationActive()) {
    error(localize("Speed-feed synchronization is not supported for circular moves."));
    return;
  }

  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (getProperty("useRadius") || isHelical()) { // radius mode does not support full arcs
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(getG17Code()), gMotionModal.format(directionCode), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      if (machineState.usePolarInterpolation) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(18), gMotionModal.format(directionCode), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      if (machineState.usePolarInterpolation) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(19), gMotionModal.format(directionCode), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else if (!getProperty("useRadius")) {
    if (isHelical() && ((getCircularSweep() < toRad(30)) || (getHelicalPitch() > 10))) { // avoid G112 issue
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(getG17Code()), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      if (machineState.usePolarInterpolation) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(18), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      if (machineState.usePolarInterpolation) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(19), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else { // use radius mode
    if (isHelical() && ((getCircularSweep() < toRad(30)) || (getHelicalPitch() > 10))) {
      linearize(tolerance);
      return;
    }
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      r = -r; // allow up to <360 deg arcs
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(getG17Code()), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_ZX:
      if (machineState.usePolarInterpolation) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(18), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_YZ:
      if (machineState.usePolarInterpolation) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(19), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

var chuckMachineFrame;
var chuckSubPosition;
function getSecondaryPullMethod(type) {
  var pullMethod = {};

  // determine if pull operation, spindle return, or both
  pullMethod.pull = false;
  pullMethod.home = false;

  switch (type) {
  case "secondary-spindle-pull":
    if (true) { // Secondary pull operations are not officially released
      error(localize("Bar pull operations are not supported.  Please use the Subspindle Return operation with an Offset value to do a bar pull operation."));
    }
    pullMethod.pullPosition = chuckSubPosition + cycle.pullingDistance;
    pullMethod.machineFrame = chuckMachineFrame;
    pullMethod.unclampMode = "keep-clamped";
    pullMethod.pull = true;
    break;
  case "secondary-spindle-return":
    pullMethod.pullPosition = cycle.feedPosition;
    pullMethod.machineFrame = cycle.useMachineFrame;
    pullMethod.unclampMode = cycle.unclampMode;

    // pull part only (when offset!=0), Return secondary spindle to home (when offset=0)
    var feedDis = 0;
    if (pullMethod.machineFrame) {
      if (hasParameter("operation:feedPlaneHeight_direct")) { // Inventor
        feedDis = getParameter("operation:feedPlaneHeight_direct");
      } else if (hasParameter("operation:feedPlaneHeightDirect")) { // HSMWorks
        feedDis = getParameter("operation:feedPlaneHeightDirect");
      }
      feedPosition = feedDis;
    } else if (hasParameter("operation:feedPlaneHeight_offset")) { // Inventor
      feedDis = getParameter("operation:feedPlaneHeight_offset");
    } else if (hasParameter("operation:feedPlaneHeightOffset")) { // HSMWorks
      feedDis = getParameter("operation:feedPlaneHeightOffset");
    }

    // Transfer part to secondary spindle
    if (pullMethod.unclampMode != "keep-clamped") {
      pullMethod.pull = feedDis != 0;
      pullMethod.home = true;
    } else {
      // pull part only (when offset!=0), Return secondary spindle to home (when offset=0)
      pullMethod.pull = feedDis != 0;
      pullMethod.home = !pullMethod.pull;
    }
    break;
  }
  return pullMethod;
}

function onCycle() {
  if ((typeof isSubSpindleCycle == "function") && isSubSpindleCycle(cycleType)) {
    if (!gotSecondarySpindle) {
      error(localize("Secondary spindle is not available."));
    }
    writeln("");
    if (hasParameter("operation-comment")) {
      var comment = getParameter("operation-comment");
      if (comment) {
        writeComment(comment);
      }
    }
    // Start of stock transfer operation(s)
    if (!machineState.stockTransferIsActive) {
      onCommand(COMMAND_STOP_SPINDLE);
      onCommand(COMMAND_COOLANT_OFF);
      if (gotSecondarySpindle && previousPartSpindle == SPINDLE_SUB) {
        writeBlock(gFormat.format(111), formatComment("Cross Axis Control cancel"));
      }

      if (cycleType != "secondary-spindle-return") {
        writeBlock(gMotionModal.format(0), gFormat.format(getProperty("controllerType") == "640MT" ? 28 : 53), barOutput.format(0)); // retract Sub Spindle
        goHome();
        if (getProperty("optionalStop")) {
          onCommand(COMMAND_OPTIONAL_STOP);
          gMotionModal.reset();
        }
      }
      writeln("");
      gSelectSpindleModal.reset();
      gFeedModeModal.reset();
      writeBlock("T" + getProperty("transferTool"));
      writeBlock(gMotionModal.format(0), gFeedModeModal.format(98), "Z0", formatComment("CLEAR"));
      forceUnlockMultiAxis();
      //onCommand(COMMAND_UNLOCK_MULTI_AXIS);

      if (cycle.stopSpindle) {
        lastSpindleSpeed = 0;
        cAxisEngageModal.reset();
        forceABC();
        gMotionModal.reset();
        writeBlock(feedMode, gPlaneModal.format(18));
        writeBlock(mFormat.format(getCode("ACTIVATE_SPINDLE", getSpindle(PART))));
        writeBlock(cAxisEngageModal.format(getCode("ENABLE_C_AXIS", getSpindle(PART))),
          formatComment("C1 AXIS ON"));
        writeBlock(gMotionModal.format(0), cOutput.format(0), formatComment("MAIN ANGLE"));
        writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(PART))),
          formatComment("C1 axis off"));
        writeBlock(mFormat.format(getCode("ACTIVATE_SPINDLE", SPINDLE_SUB)));
        writeBlock(cAxisEngageModal.format(getCode("ENABLE_C_AXIS", SPINDLE_SUB)),
          formatComment("C2 AXIS ON"));
        writeBlock(gFormat.format(110), "C2", formatComment("Cross Axis Control"));
        gMotionModal.reset();
        forceABC();
        writeBlock(gMotionModal.format(0), cOutput.format(cycle.spindleOrientation), formatComment("SUB ANGLE"));
        writeBlock(gFormat.format(111), formatComment("Cross Axis Control Cancel"));
        gMotionModal.reset();
        writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", SPINDLE_SUB)),
          formatComment("C2 axis off"));
        writeBlock(mFormat.format(getCode("ACTIVATE_SPINDLE", getSpindle(PART))));
      }
      gFeedModeModal.reset();
      var feedMode;
      if (currentSection.feedMode == FEED_PER_REVOLUTION) {
        feedMode = gFeedModeModal.format(getCode("FEED_MODE_UNIT_REV", getSpindle(TOOL)));
      } else {
        feedMode = gFeedModeModal.format(getCode("FEED_MODE_UNIT_MIN", getSpindle(TOOL)));
      }
      gPlaneModal.reset();
      if (!getProperty("optimizeCAxisSelect")) {
        cAxisEngageModal.reset();
      }
    }

    switch (cycleType) {
    case "secondary-spindle-grab":
      if (currentSection.partCatcher) {
        engagePartCatcher(true);
      }
      /*writeBlock(mFormat.format(getCode("INTERLOCK_BYPASS", getSecondarySpindle())), formatComment("INTERLOCK BYPASS"));*/

      clampChuck(getSecondarySpindle(), UNCLAMP);
      gSpindleModeModal.reset();
      if (currentSection.partCatcher) {
        writeBlock(mFormat.format(getCode("PART_CATCHER_OFF", true)), formatComment(localize("PART CATCHER OFF")));
      }
      if (airCleanChuck) {
      // clean out chips
        writeBlock(mFormat.format(getCode("AIR_BLAST_ON", getSpindle(PART))), formatComment("MAIN SPINDLE AIR BLOW ON"));
        onDwell(1);
        writeBlock(mFormat.format(getCode("AIR_BLAST_OFF", getSpindle(PART))), formatComment("MAIN SPINDLE AIR BLOW OFF"));
        onDwell(1);
        writeBlock(mFormat.format(getCode("AIR_BLAST_ON", getSecondarySpindle())), formatComment("SUB SPINDLE AIR BLOW ON"));
        onDwell(1);
        writeBlock(mFormat.format(getCode("COOLANT_AIR_OFF", getSecondarySpindle())), formatComment("SUB SPINDLE AIR BLOW OFF"));
        onDwell(1);
      }
      if (cycle.stopSpindle) { // no spindle rotation
        /*writeBlock(
          mFormat.format(getCode("ORIENT_SPINDLE", getSpindle(PART))),
          mFormat.format(getCode("ORIENT_SPINDLE", getSecondarySpindle())),
          formatComment("SPINDLE ORIENTATION")
        );*/
      } else if (transferType == TRANSFER_SPEED) { // speed synchronization
        // start synchronization
        writeBlock(gSelectSpindleModal.format(getCode("ACTIVATE_SPINDLE", getSpindle(PART))));
        writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(PART))));
        writeBlock(
          gSpindleModeModal.format(97),
          sOutput.format(cycle.spindleSpeed),
          mFormat.format(getCode("START_SPINDLE_CW", getSpindle(PART))));
        writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_SPEED")), formatComment("SPEED SYNCHRONIZATION"));
        //writeBlock(gFormat.format(53), "H" + abcFormat.format(0), formatComment("REFERENCE RETURN OF C"));
        //writeBlock(mFormat.format(60), formatComment("PARKING MAIN SPINDLE"));
      } else { // phase syncronization
        writeBlock(mFormat.format(getCode("STOP_SPINDLE", SPINDLE_MAIN)), formatComment("MAIN SPINDLE STOP"));
        writeBlock(mFormat.format(getCode("STOP_SPINDLE", SPINDLE_SUB)), formatComment("SUB SPINDLE STOP"));
        writeBlock(gSelectSpindleModal.format(getCode("ACTIVATE_SPINDLE", getSpindle(PART))));
        writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(PART))));
        writeBlock(
          gSpindleModeModal.format(97),
          sOutput.format(cycle.spindleSpeed),
          mFormat.format(getCode("START_SPINDLE_CW", getSpindle(PART))));
        forceSpindleSpeed = false;
        writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_PHASE")), formatComment("PHASE SYNCHRONIZATION"));
      }
      lastSpindleMode = tool.getSpindleMode();
      lastSpindleSpeed = cycle.spindleSpeed;
      lastSpindleDirection = tool.clockwise;
      writeBlock(mFormat.format(540), formatComment("Transfer Mode on"));

      // approach part
      gMotionModal.reset();
      if (cycle.useMachineFrame && getProperty("controllerType") == "640MT") {
        error(localize("Cannot use Machine Position as the Chuck Plane Mode with 640MT control."));
      }
      writeBlock(conditional(cycle.useMachineFrame, gFormat.format(53)), gMotionModal.format(0), subBOutput.format(cycle.feedPosition) + "]", formatComment("MOVE HD2 TO APPROACH"));
      //For possible pull operation
      subSupport = cycle.chuckPosition;
      if (transferUseTorque) { //G31 Mode
        writeBlock("#3030=70", formatComment("THRUST FACTOR"));
        writeBlock(mFormat.format(getCode("TORQUE_SKIP_ON", getSpindle(PART))), formatComment("PUSH PRESS ON"));
        writeBlock(conditional(cycle.useMachineFrame, gFormat.format(53)), gMotionModal.format(31), subBOutput.format(cycle.chuckPosition) + "]", getFeed(cycle.feedrate), formatComment("G31 PUSH"));
        writeBlock(mFormat.format(getCode("TORQUE_SKIP_OFF", getSpindle(PART))), formatComment("PUSH PRESS OFF"));
      } else {
        writeBlock(conditional(cycle.useMachineFrame, gFormat.format(53)), gMotionModal.format(1), subBOutput.format(cycle.chuckPosition) + "]", getFeed(cycle.feedrate));
      }
      gMotionModal.reset();
      clampChuck(getSecondarySpindle(), CLAMP);
      machineState.stockTransferIsActive = true;
      break;
    case "secondary-spindle-return":
    case "secondary-spindle-pull":
      var pullMethod = getSecondaryPullMethod(cycleType);
      if (pullMethod.pull) {
        if (cycle.useMachineFrame && getProperty("controllerType") == "640MT") {
          error(localize("Cannot use Machine Position as the Chuck Plane Mode with 640MT control."));
        }
        clampChuck(getSpindle(PART), UNCLAMP);
        writeBlock(conditional(cycle.useMachineFrame, gFormat.format(53)), gMotionModal.format(1),
          subBOutput.format(subSupport) + subBFormat.format(cycle.feedPosition) + "]",
          getFeed(cycle.feedrate),
          formatComment("BAR PULL")
        );
      }
      if (pullMethod.home) {
        if (cycle.unclampMode == "unclamp-secondary") { // simple bar pulling operation
          clampChuck(getSpindle(PART), CLAMP);
          clampChuck(getSecondarySpindle(), UNCLAMP);
        } else if (pullMethod.unclampMode == "unclamp-primary") {
          clampChuck(getSpindle(PART), UNCLAMP);
        }
        writeBlock(mFormat.format(541), formatComment("Transfer Mode Cancel"));
        writeBlock(gMotionModal.format(0), gFormat.format(getProperty("controllerType") == "640MT" ? 28 : 53), barOutput.format(0), formatComment("SUB SPINDLE RETURN"));
        writeBlock(gFeedModeModal.format(99));
        if (transferType == TRANSFER_SPEED) {
          writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_SPEED_OFF", getSpindle(PART))), formatComment("SYNCHRONIZATION OFF"));
        } else if (transferType == TRANSFER_PHASE) {
          writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_SPEED_OFF", getSpindle(PART))), formatComment("SYNCHRONIZATION OFF"));
          writeBlock(mFormat.format(getCode("STOP_SPINDLE", SPINDLE_SUB)), formatComment("SUB SPINDLE STOP"));
        }
        machineState.stockTransferIsActive = false;
      } else {
        clampChuck(getSpindle(PART), CLAMP);
        machineState.stockTransferIsActive = true;
      }
      break;
    }
  }

  if (cycleType == "stock-transfer") {
    warning(localize("Stock transfer is not supported. Required machine specific customization."));
    return;
  } else if (!getProperty("useCycles") && tapping) {
    startSpindle(false, false);
  }
}

var saveShowSequenceNumbers;
var pathBlockNumber = {start:0, end:0};
var isCannedCycle = false;

function onCyclePath() {
  saveShowSequenceNumbers = showSequenceNumbers;
  isCannedCycle = true;
  // buffer all paths and stop feeds being output
  feedOutput.disable();
  showSequenceNumbers = "false";
  redirectToBuffer();
  gMotionModal.reset();
  xOutput.reset();
  zOutput.reset();
}

function onCyclePathEnd() {
  showSequenceNumbers = saveShowSequenceNumbers; // reset property to initial state
  feedOutput.enable();
  var cyclePath = String(getRedirectionBuffer()).split(EOL); // get cycle path from buffer
  closeRedirection();
  for (line in cyclePath) { // remove empty elements
    if (cyclePath[line] == "") {
      cyclePath.splice(line);
    }
  }

  var verticalPasses;
  if (cycle.profileRoughingCycle == 0) {
    verticalPasses = false;
  } else if (cycle.profileRoughingCycle == 1) {
    verticalPasses = true;
  } else {
    error(localize("Unsupported passes type."));
    return;
  }
  // output cycle data
  switch (cycleType) {
  case "turning-canned-rough":
    if (getProperty("controllerType") == "Matrix" || getProperty("controllerType") == "Smooth") {
      writeBlock(gFormat.format(verticalPasses ? 72 : 71),
        (verticalPasses ? "W" : "U") + spatialFormat.format(cycle.depthOfCut),
        "R" + spatialFormat.format(cycle.retractLength)
      );
      writeBlock(gFormat.format(verticalPasses ? 72 : 71),
        "P" + (getStartEndSequenceNumber(cyclePath, true)),
        "Q" + (getStartEndSequenceNumber(cyclePath, false)),
        "U" + xFormat.format(cycle.xStockToLeave),
        "W" + spatialFormat.format(cycle.zStockToLeave),
        getFeed(cycle.cutfeedrate)
      );
    } else {
      writeBlock(gFormat.format(verticalPasses ? 72 : 71),
        "P" + (getStartEndSequenceNumber(cyclePath, true)),
        "Q" + (getStartEndSequenceNumber(cyclePath, false)),
        "U" + xFormat.format(cycle.xStockToLeave),
        "W" + spatialFormat.format(cycle.zStockToLeave),
        "D" + spatialFormat.format(cycle.depthOfCut),
        getFeed(cycle.cutfeedrate)
      );
    }
    break;
  default:
    error(localize("Unsupported turning canned cycle."));
  }

  for (var i = 0; i < cyclePath.length; ++i) {
    if (i == 0 || i == (cyclePath.length - 1)) { // write sequence number on first and last line of the cycle path
      showSequenceNumbers = "true";
      if ((i == 0 && pathBlockNumber.start != sequenceNumber) || (i == (cyclePath.length - 1) && pathBlockNumber.end != sequenceNumber)) {
        error(localize("Mismatch of start/end block number in turning canned cycle."));
        return;
      }
    }
    writeBlock(cyclePath[i]); // output cycle path
    showSequenceNumbers = saveShowSequenceNumbers; // reset property to initial state
    isCannedCycle = false;
  }
}

function getStartEndSequenceNumber(cyclePath, start) {
  if (start) {
    pathBlockNumber.start = sequenceNumber + conditional(saveShowSequenceNumbers == "true", getProperty("sequenceNumberIncrement"));
    return pathBlockNumber.start;
  } else {
    pathBlockNumber.end = sequenceNumber + getProperty("sequenceNumberIncrement") + conditional(saveShowSequenceNumbers == "true", (cyclePath.length - 1) * getProperty("sequenceNumberIncrement"));
    return pathBlockNumber.end;
  }
}

function getCommonCycle(x, y, z, r, includeRcode) {

  // R-value is incremental position from current position
  var raptoS = "";
  if ((r !== undefined) && includeRcode) {
    raptoS = "R" + spatialFormat.format(r);
  }

  if (machineState.usePolarCoordinates) {
    var polarPosition = getPolarPosition(x, y, z);
    setCurrentPositionAndDirection(polarPosition);
    cOutput.reset();
    return [xOutput.format(polarPosition.first.x), cOutput.format(polarPosition.second.z),
      zOutput.format(polarPosition.first.z),
      raptoS];
  } else {
    return [xOutput.format(x), yOutput.format(y),
      zOutput.format(z),
      raptoS];
  }
}

function writeCycleClearance(plane, clearance) {
  var currentPosition = getCurrentPosition();
  if (true) {
    onCycleEnd();
    switch (plane) {
    case 17:
      writeBlock(gMotionModal.format(0), zOutput.format(clearance));
      break;
    case 18:
      writeBlock(gMotionModal.format(0), yOutput.format(clearance));
      break;
    case 19:
      writeBlock(gMotionModal.format(0), xOutput.format(clearance));
      break;
    default:
      error(localize("Unsupported drilling orientation."));
      return;
    }
  }
}

var threadStart;
var threadEnd;
function moveToThreadStart(x, y, z) {
  var cuttingAngle = 0;
  if (hasParameter("operation:infeedAngle")) {
    cuttingAngle = getParameter("operation:infeedAngle");
  }
  if (cuttingAngle != 0) {
    var zz;
    if (isFirstCyclePoint()) {
      threadStart = getCurrentPosition();
      threadEnd = new Vector(x, y, z);
    } else {
      var zz = threadStart.z - (Math.abs(threadEnd.x - x) * Math.tan(toRad(cuttingAngle)));
      writeBlock(gMotionModal.format(0), zOutput.format(zz));
      threadStart.setZ(zz);
      threadEnd = new Vector(x, y, z);
    }
  }
}

function onCyclePoint(x, y, z) {

  if (!getProperty("useCycles") || currentSection.isMultiAxis()) {
    expandCyclePoint(x, y, z);
    return;
  }

  var plane = gPlaneModal.getCurrent();
  var localZOutput = zOutput;
  if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1)) ||
      isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, -1))) {
    plane = 17; // XY plane
    localZOutput = zOutput;
  } else if (Vector.dot(currentSection.workPlane.forward, new Vector(0, 0, 1)) < 1e-7) {
    plane = 19; // YZ plane
    localZOutput = xOutput;
  } else {
    expandCyclePoint(x, y, z);
    return;
  }

  switch (cycleType) {
  case "thread-turning":
    if (getProperty("useSimpleThread") ||
      (hasParameter("operation:doMultipleThreads") && (getParameter("operation:doMultipleThreads") != 0)) ||
      (hasParameter("operation:infeedMode") && (getParameter("operation:infeedMode") != "constant"))) {
      var r = -cycle.incrementalX; // positive if taper goes down - delta radius
      moveToThreadStart(x, y, z);
      xOutput.reset();
      zOutput.reset();
      writeBlock(
        gMotionModal.format(92),
        xOutput.format(x),
        yOutput.format(y),
        zOutput.format(z),
        conditional(zFormat.isSignificant(r), g92ROutput.format(r)),
        pitchOutput.format(cycle.pitch)
      );
    } else {
      if (isLastCyclePoint()) {
        // thread height and depth of cut
        var threadHeight = getParameter("operation:threadDepth");
        var firstDepthOfCut = threadHeight / getParameter("operation:numberOfStepdowns");

        // first G76 block
        var repeatPass = hasParameter("operation:nullPass") ? getParameter("operation:nullPass") : 0;
        var chamferWidth = 10; // Pullout-width is 1*thread-lead in 1/10's;
        var materialAllowance = 0; // Material allowance for finishing pass
        var cuttingAngle = getParameter("operation:infeedAngle", 30) * 2; // Angle is not stored with tool. toDeg(tool.getTaperAngle());
        var pcode = repeatPass * 10000 + chamferWidth * 100 + cuttingAngle;
        gCycleModal.reset();

        if (getProperty("controllerType") == "Matrix" || getProperty("controllerType") == "Smooth") {
          writeBlock(
            gCycleModal.format(76),
            threadP1Output.format(pcode),
            threadQOutput.format(firstDepthOfCut),
            threadROutput.format(materialAllowance)
          );
          // second G76 block
          var r = -cycle.incrementalX; // positive if taper goes down - delta radius
          gCycleModal.reset();
          writeBlock(
            gCycleModal.format(76),
            xOutput.format(x),
            zOutput.format(z),
            conditional(zFormat.isSignificant(r), threadROutput.format(r)),
            threadP2Output.format(threadHeight),
            threadQOutput.format(firstDepthOfCut),
            pitchOutput.format(cycle.pitch)
          );
        } else {
          var i = -cycle.incrementalX;
          writeBlock(
            gCycleModal.format(76),
            xOutput.format(x),
            zOutput.format(z),
            "K" + (threadHeight),
            "D" + (firstDepthOfCut),
            "A" + (cuttingAngle),
            (threadIOutput.format(i)),
            pitchOutput.format(cycle.pitch)
          );
        }
      }
    }
    forceFeed();
    return;
  }

  // clamp the C-axis if necessary
  // the C-axis is automatically unclamped by the controllers during cycles
  var lockCode = "";
  if (!machineState.axialCenterDrilling && !machineState.isTurningOperation) {
    lockCode = mFormat.format(getCode("LOCK_MULTI_AXIS", getSpindle(PART)));
  }

  var forceCycle = false;
  switch (cycleType) {
  case "tapping-with-chip-breaking":
  case "left-tapping-with-chip-breaking":
  case "right-tapping-with-chip-breaking":
    forceCycle = true;
    if (!isFirstCyclePoint()) {
      writeBlock(gCycleModal.format(80));
      gMotionModal.reset();
    }
  }

  var rapto = 0;
  if (forceCycle || isFirstCyclePoint()) { // first cycle point
    rapto = cycle.retract - cycle.clearance;
    var P = !cycle.dwell ? 0 : clamp(1, cycle.dwell * 1000, 99999999); // in milliseconds

    switch (cycleType) {
    case "drilling":
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      writeBlock(
        gCycleModal.format(plane == 19 ? 87 : 83),
        getCommonCycle(x, y, z, rapto, true),
        conditional(P > 0, pOutput.format(P)),
        getFeed(cycle.feedrate),
        lockCode
      );
      break;
    case "chip-breaking":
      expandCyclePoint(x, y, z);
      break;
    case "deep-drilling":
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      writeBlock(
        gCycleModal.format(plane == 19 ? 87 : 83),
        getCommonCycle(x, y, z, rapto, true),
        conditional(cycle.incrementalDepth > 0, peckOutput.format(cycle.incrementalDepth)),
        conditional(P > 0, pOutput.format(P)),
        getFeed(cycle.feedrate),
        lockCode
      );
      break;
    case "tapping":
    case "right-tapping":
    case "left-tapping":
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      if (getProperty("useRigidTapping")) {
        writeBlock(
          gCycleModal.format(plane == 19 ? 88.2 : 84.2),
          getCommonCycle(x, y, z, rapto, true),
          getFeed(cycle.feedrate),
          lockCode
        );
      } else {
        writeBlock(
          gCycleModal.format(plane == 19 ? 88 : 84),
          getCommonCycle(x, y, z, rapto, true),
          getFeed(cycle.feedrate),
          lockCode
        );
      }
      break;
    case "tapping-with-chip-breaking":
    case "left-tapping-with-chip-breaking":
    case "right-tapping-with-chip-breaking":
      var u = cycle.stock;
      var step = cycle.incrementalDepth;
      var first = true;

      while (u > cycle.bottom) {
        if (step < cycle.minimumIncrementalDepth) {
          step = cycle.minimumIncrementalDepth;
        }
        u -= step;
        step -= cycle.incrementalDepthReduction;
        gCycleModal.reset(); // required
        u = Math.max(u, cycle.bottom);
        //Sub Spindle needs reversed here
        var depth = u * (getSpindle(PART) == SPINDLE_MAIN ? 1 : -1);

        if (first) {
          first = false;
          writeBlock(
            gCycleModal.format(plane == 19 ? 88.2 : 84.2),
            getCommonCycle(plane == 19 ? depth : x, y, plane == 19 ? z : depth, rapto, true),
            getFeed(cycle.feedrate),
            lockCode
          );
        } else {
          if (plane == 19) {
            zOutput.reset();
            writeBlock(
              xOutput.format(depth),
              zOutput.format(z)
            );
          } else {
            xOutput.reset();
            writeBlock(
              xOutput.format(machineState.usePolarCoordinates ? getPolarPosition().x : x),
              "Z" + zFormat.format(depth)
            );
          }
        }
      }
      forceFeed();
      break;
    case "boring":
      if (feedFormat.getResultingValue(cycle.feedrate) != feedFormat.getResultingValue(cycle.retractFeedrate)) {
        expandCyclePoint(x, y, z);
        break;
      }
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      writeBlock(
        gCycleModal.format(plane == 19 ? 89 : 85),
        getCommonCycle(x, y, z, rapto, true),
        conditional(P > 0, pOutput.format(P)),
        getFeed(cycle.feedrate),
        lockCode
      );
      break;
    default:
      expandCyclePoint(x, y, z);
    }
  } else { // position to subsequent cycle points
    if (cycleExpanded) {
      expandCyclePoint(x, y, z);
    } else {
      var step = 0;
      if (cycleType == "chip-breaking" || cycleType == "deep-drilling") {
        step = cycle.incrementalDepth;
      }
      writeBlock(getCommonCycle(x, y, z, rapto, false), conditional(step > 0, peckOutput.format(step)), lockCode);
    }
  }
}

function onCycleEnd() {
  if (!cycleExpanded && !machineState.stockTransferIsActive) {
    writeBlock(gCycleModal.format(80));
    gMotionModal.reset();
  }
}

function onPassThrough(text) {
  writeBlock(text);
}

function onParameter(name, value) {
  var invalid = false;
  switch (name) {
  case "action":
    if (String(value).toUpperCase() == "PARTEJECT") {
      ejectRoutine = true;
    } else if (String(value).toUpperCase() == "USEPOLARMODE" ||
    String(value).toUpperCase() == "USEPOLARINTERPOLATION") {
      forcePolarInterpolation = true;
      forcePolarCoordinates = false;
    } else if (String(value).toUpperCase() == "USEXZCMODE" ||
    String(value).toUpperCase() == "USEPOLARCOORDINATES") {
      forcePolarCoordinates = true;
      forcePolarInterpolation = false;
    } else {
      var sText1 = String(value);
      var sText2 = new Array();
      sText2 = sText1.split(":");
      if (sText2.length != 2) {
        error(localize("Invalid action command: ") + value);
        return;
      }
      if (sText2[0].toUpperCase() == "TRANSFERTYPE") {
        transferType = parseToggle(sText2[1], "PHASE", "SPEED");
        if (transferType == undefined) {
          error(localize("TransferType must be Phase or Speed"));
          return;
        }
      } else if (sText2[0].toUpperCase() == "TRANSFERUSETORQUE") {
        transferUseTorque = parseToggle(sText2[1], "YES", "NO");
        if (transferUseTorque == undefined) {
          invalid = true;
        }
      } else {
        invalid = true;
      }
    }
  }
  if (invalid) {
    error(localize("Invalid action parameter: ") + sText2[0] + ":" + sText2[1]);
    return;
  }
}

function parseToggle() {
  var stat = undefined;
  for (i = 1; i < arguments.length; i++) {
    if (String(arguments[0]).toUpperCase() == String(arguments[i]).toUpperCase()) {
      if (String(arguments[i]).toUpperCase() == "YES") {
        stat = true;
      } else if (String(arguments[i]).toUpperCase() == "NO") {
        stat = false;
      } else {
        stat = i - 1;
        break;
      }
    }
  }
  return stat;
}

var currentCoolantMode = COOLANT_OFF;
var currentCoolantTurret = 1;
var coolantOff = undefined;
var isOptionalCoolant = false;
var forceCoolant = false;

function setCoolant(coolant, turret) {
  var coolantCodes = getCoolantCodes(coolant, turret);
  if (Array.isArray(coolantCodes)) {
    if (singleLineCoolant) {
      skipBlock = isOptionalCoolant;
      writeBlock(coolantCodes.join(getWordSeparator()));
    } else {
      for (var c in coolantCodes) {
        skipBlock = isOptionalCoolant;
        writeBlock(coolantCodes[c]);
      }
    }
    return undefined;
  }
  return coolantCodes;
}

function getCoolantCodes(coolant, turret) {
  turret = gotMultiTurret ? (turret == undefined ? 1 : turret) : 1;
  isOptionalCoolant = false;
  var multipleCoolantBlocks = new Array(); // create a formatted array to be passed into the outputted line
  if (!coolants) {
    error(localize("Coolants have not been defined."));
  }
  if (tool.type == TOOL_PROBE) { // avoid coolant output for probing
    coolant = COOLANT_OFF;
  }
  if (coolant == currentCoolantMode && turret == currentCoolantTurret) {
    if ((typeof operationNeedsSafeStart != "undefined" && operationNeedsSafeStart) && coolant != COOLANT_OFF) {
      isOptionalCoolant = true;
    } else if (!forceCoolant || coolant == COOLANT_OFF) {
      return undefined; // coolant is already active
    }
  }
  if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF) && (coolantOff != undefined) && !forceCoolant && !isOptionalCoolant) {
    if (Array.isArray(coolantOff)) {
      for (var i in coolantOff) {
        multipleCoolantBlocks.push(coolantOff[i]);
      }
    } else {
      multipleCoolantBlocks.push(coolantOff);
    }
  }
  forceCoolant = false;

  var m;
  var coolantCodes = {};
  for (var c in coolants) { // find required coolant codes into the coolants array
    if (coolants[c].id == coolant) {
      var localCoolant = parseCoolant(coolants[c], turret);
      localCoolant = typeof localCoolant == "undefined" ? coolants[c] : localCoolant;
      coolantCodes.on = localCoolant.on;
      if (localCoolant.off != undefined) {
        coolantCodes.off = localCoolant.off;
        break;
      } else {
        for (var i in coolants) {
          if (coolants[i].id == COOLANT_OFF) {
            coolantCodes.off = localCoolant.off;
            break;
          }
        }
      }
    }
  }
  if (coolant == COOLANT_OFF) {
    m = !coolantOff ? coolantCodes.off : coolantOff; // use the default coolant off command when an 'off' value is not specified
  } else {
    coolantOff = coolantCodes.off;
    m = coolantCodes.on;
  }

  if (!m) {
    onUnsupportedCoolant(coolant);
    m = 9;
  } else {
    if (Array.isArray(m)) {
      for (var i in m) {
        multipleCoolantBlocks.push(m[i]);
      }
    } else {
      multipleCoolantBlocks.push(m);
    }
    currentCoolantMode = coolant;
    currentCoolantTurret = turret;
    for (var i in multipleCoolantBlocks) {
      if (typeof multipleCoolantBlocks[i] == "number") {
        multipleCoolantBlocks[i] = mFormat.format(multipleCoolantBlocks[i]);
      }
    }
    return multipleCoolantBlocks; // return the single formatted coolant value
  }
  return undefined;
}

function parseCoolant(coolant, turret) {
  var localCoolant;
  if (getSpindle(PART) == SPINDLE_MAIN) {
    localCoolant = turret == 1 ? coolant.spindle1t1 : coolant.spindle1t2;
    localCoolant = typeof localCoolant == "undefined" ? coolant.spindle1 : localCoolant;
  } else if (getSpindle(PART) == SPINDLE_LIVE) {
    localCoolant = turret == 1 ? coolant.spindleLivet1 : coolant.spindleLivet2;
    localCoolant = typeof localCoolant == "undefined" ? coolant.spindleLive : localCoolant;
  } else {
    localCoolant = turret == 1 ? coolant.spindle2t1 : coolant.spindle2t2;
    localCoolant = typeof localCoolant == "undefined" ? coolant.spindle2 : localCoolant;
  }
  localCoolant = typeof localCoolant == "undefined" ? (turret == 1 ? coolant.turret1 : coolant.turret2) : localCoolant;
  localCoolant = typeof localCoolant == "undefined" ? coolant : localCoolant;
  return localCoolant;
}

function isSpindleSpeedDifferent() {
  var areDifferent = false;
  if (isFirstSection()) {
    areDifferent = true;
  }
  if (lastSpindleDirection != tool.clockwise) {
    areDifferent = true;
  }
  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    var _spindleSpeed = tool.surfaceSpeed * ((unit == MM) ? 1 / 1000.0 : 1 / 12.0);
    if ((lastSpindleMode != SPINDLE_CONSTANT_SURFACE_SPEED) ||
        rpmFormat.areDifferent(lastSpindleSpeed, _spindleSpeed)) {
      areDifferent = true;
    }
  } else {
    if ((lastSpindleMode != SPINDLE_CONSTANT_SPINDLE_SPEED) ||
        rpmFormat.areDifferent(lastSpindleSpeed, spindleSpeed)) {
      areDifferent = true;
    }
  }
  return areDifferent;
}

function onSpindleSpeed(spindleSpeed) {
  if (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) {
    startSpindle(false, false, getFramePosition(currentSection.getInitialPosition()), spindleSpeed);
  }
}

function startSpindle(tappingMode, forceRPMMode, initialPosition, rpm) {
  var spindleDir;
  var spindleMode;
  var _spindleSpeed = spindleSpeed;
  if (rpm !== undefined) {
    _spindleSpeed = rpm;
  }

  gSpindleModeModal.reset();

  if ((getSpindle(PART) == SPINDLE_SUB) && !gotSecondarySpindle) {
    error(localize("Secondary spindle is not available."));
    return;
  }

  if (tappingMode) {
    spindleDir = mFormat.format(getCode("RIGID_TAPPING", getSpindle(TOOL)));
  } else {
    spindleDir = mFormat.format(tool.clockwise ? getCode("START_SPINDLE_CW", getSpindle(TOOL)) : getCode("START_SPINDLE_CCW", getSpindle(TOOL)));
  }

  var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, getProperty("maximumSpindleSpeed")) : getProperty("maximumSpindleSpeed");
  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    _spindleSpeed = tool.surfaceSpeed * ((unit == MM) ? 1 / 1000.0 : 1 / 12.0);
    if (forceRPMMode) { // RPM mode is forced until move to initial position
      if (xFormat.getResultingValue(initialPosition.x) == 0) {
        _spindleSpeed = maximumSpindleSpeed;
      } else {
        _spindleSpeed = Math.min((_spindleSpeed * ((unit == MM) ? 1000.0 : 12.0) / (Math.PI * Math.abs(initialPosition.x * 2))), maximumSpindleSpeed);
      }
      spindleMode = getCode("CONSTANT_SURFACE_SPEED_OFF", getSpindle(TOOL));
    } else {
      spindleMode = getCode("CONSTANT_SURFACE_SPEED_ON", getSpindle(TOOL));
    }
  } else {
    spindleMode = getCode("CONSTANT_SURFACE_SPEED_OFF", getSpindle(TOOL));
  }

  if (machineState.isTurningOperation || machineState.axialCenterDrilling) {
    writeBlock(
      gSpindleModeModal.format(spindleMode),
      sOutput.format(_spindleSpeed),
      spindleDir,
      conditional(getProperty("controllerType") != "640MT", rcssOutput.format(getCode("SELECT_SPINDLE", getSpindle(PART))))
    );
  } else {
    writeBlock(
      gSpindleModeModal.format(spindleMode),
      sOutput.format(_spindleSpeed),
      spindleDir
    );
  }
  lastSpindleMode = tool.getSpindleMode();
  lastSpindleSpeed = _spindleSpeed;
  lastSpindleDirection = tool.clockwise;
}

var defaultDwellTime = 1;
function clampChuck(_spindle, _clamp, _dwellTime) {
  _dwellTime = _dwellTime != undefined ? _dwellTime : (cycle.dwell != undefined ? cycle.dwell : defaultDwellTime);
  var seconds;
  if (_spindle == SPINDLE_MAIN) {
    if (_clamp != machineState.mainChuckIsClamped) {
      writeBlock(mFormat.format(getCode(_clamp ? "CLAMP_CHUCK" : "UNCLAMP_CHUCK", _spindle)),
        formatComment(_clamp ? "CLAMP MAIN CHUCK" : "UNCLAMP MAIN CHUCK"));
      machineState.mainChuckIsClamped = _clamp;
      seconds = _dwellTime;
    }
  } else {
    if (_clamp != machineState.subChuckIsClamped) {
      writeBlock(mFormat.format(getCode(_clamp ? "CLAMP_CHUCK" : "UNCLAMP_CHUCK", _spindle)),
        formatComment(_clamp ? "CLAMP SUB CHUCK" : "UNCLAMP SUB CHUCK"));
      machineState.subChuckIsClamped = _clamp;
      seconds = _dwellTime;
    }
  }
  if (seconds) {
    onDwell(seconds);
  }
  machineState.spindlesAreAttached = machineState.mainChuckIsClamped && machineState.subChuckIsClamped;
}

function onCommand(command) {
  switch (command) {
  case COMMAND_COOLANT_OFF:
    setCoolant(COOLANT_OFF);
    break;
  case COMMAND_COOLANT_ON:
    setCoolant(COOLANT_FLOOD);
    break;
  case COMMAND_LOCK_MULTI_AXIS:
    writeBlock(cAxisBrakeModal.format(getCode("LOCK_MULTI_AXIS", getSpindle(PART))));
    break;
  case COMMAND_UNLOCK_MULTI_AXIS:
    writeBlock(cAxisBrakeModal.format(getCode("UNLOCK_MULTI_AXIS", getSpindle(PART))));
    break;
  case COMMAND_OPEN_DOOR:
    if (gotDoorControl) {
      writeBlock(mFormat.format(24)); // optional
    }
    break;
  case COMMAND_CLOSE_DOOR:
    if (gotDoorControl) {
      writeBlock(mFormat.format(25)); // optional
    }
    break;
  case COMMAND_BREAK_CONTROL:
    break;
  case COMMAND_TOOL_MEASURE:
    break;
  case COMMAND_ACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_DEACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    forceCoolant = true;
    break;
  case COMMAND_OPTIONAL_STOP:
    writeBlock(mFormat.format(1));
    forceSpindleSpeed = true;
    forceCoolant = true;
    break;
  case COMMAND_END:
    writeBlock(mFormat.format(2));
    break;
  case COMMAND_STOP_SPINDLE:
    writeBlock(mFormat.format(getCode("STOP_SPINDLE", activeSpindle)));
    sOutput.reset();
    break;
  case COMMAND_START_SPINDLE:
    startSpindle(false, true, false, spindleSpeed);
    return;
  case COMMAND_ORIENTATE_SPINDLE:
    if (machineState.isTurningOperation || machineState.axialCenterDrilling) {
      writeBlock(mFormat.format(getCode("ORIENT_SPINDLE", getSpindle(PART))));
    } else {
      error(localize("Spindle orientation is not supported for live tooling."));
      return;
    }
    break;
  case COMMAND_SPINDLE_CLOCKWISE:
    writeBlock(mFormat.format(getCode("START_SPINDLE_CW", getSpindle(TOOL))));
    break;
  case COMMAND_SPINDLE_COUNTERCLOCKWISE:
    writeBlock(mFormat.format(getCode("START_SPINDLE_CCW", getSpindle(TOOL))));
    break;
  // case COMMAND_CLAMP: // add support for clamping
  // case COMMAND_UNCLAMP: // add support for clamping
  default:
    onUnsupportedCommand(command);
  }
}

/**
 Buffer Manual NC commands for processing later
*/
var bufferPassThrough = false; // enable to output the Pass Through commands until after ending the previous section
var manualNC = [];
function onManualNC(command, value) {
  if (command == COMMAND_PASS_THROUGH && bufferPassThrough) {
    manualNC.push({command:command, value:value});
  } else {
    expandManualNC(command, value);
  }
}

/**
 Processes the Manual NC commands
 Pass the desired command to process or leave argument list blank to process all buffered commands
*/
function executeManualNC(command) {
  for (var i = 0; i < manualNC.length; ++i) {
    if (!command || (command == manualNC[i].command)) {
      expandManualNC(manualNC[i].command, manualNC[i].value);
    }
  }
  for (var i = manualNC.length - 1; i >= 0; --i) {
    if (!command || (command == manualNC[i].command)) {
      manualNC.splice(i, 1);
    }
  }
}

/** Returns the next used tool past the transfer operations. */
function getNextTool() {
  var nextTool = 0;
  var numberOfSections = getNumberOfSections();
  for (var i = getNextSection().getId(); i < numberOfSections; ++i) {
    var section = getSection(i);
    if (!section.hasCycle("secondary-spindle-grab") && !section.hasCycle("secondary-spindle-return")) {
      nextTool = section.getTool().number;
      break;
    }
  }
  return nextTool;
}

function getG17Code() {
  return machineState.usePolarInterpolation ? 17 : 17;
}

function ejectPart() {
  gMotionModal.reset();
  writeBlock(cAxisBrakeModal.format(getCode("UNLOCK_MULTI_AXIS", previousPartSpindle)));
  if (gotSecondarySpindle && previousPartSpindle == SPINDLE_SUB) {
    writeBlock(gFormat.format(111), formatComment("Cross Axis Control cancel"));
  }
  goHome(); // Position all axes to home position
  //writeBlock(mFormat.format(getCode("UNLOCK_MULTI_AXIS", getSpindle(PART))));
  if (!getProperty("optimizeCAxisSelect")) {
    cAxisEngageModal.reset();
  }
  if (getProperty("optionalStop")) {
    onCommand(COMMAND_OPTIONAL_STOP);
    gMotionModal.reset();
  }
  writeln("");
  if (getProperty("showSequenceNumbers") == "toolChange") {
    writeCommentSeqno(localize("PART EJECT"));
  } else {
    writeComment(localize("PART EJECT"));
  }
  writeBlock(gMotionModal.format(0), gFormat.format(28), barOutput.format(0)); // retract bar feeder
  writeBlock(mFormat.format(getCode("ACTIVATE_SPINDLE", SPINDLE_SUB)));
  writeBlock(
    gFeedModeModal.format(getCode("FEED_MODE_UNIT_MIN", getSpindle(TOOL))),
    gPlaneModal.format(getG17Code()),
    cAxisEngageModal.format(getCode("DISABLE_C_AXIS", SPINDLE_SUB))
  );
  // setCoolant(COOLANT_THROUGH_TOOL);
  gSpindleModeModal.reset();
  writeBlock(
    gSpindleModeModal.format(getCode("CONSTANT_SURFACE_SPEED_OFF", getSpindle(TOOL))),
    sOutput.format(50),
    mFormat.format(getCode("START_SPINDLE_CW", SPINDLE_SUB))
  );
  // writeBlock(mFormat.format(getCode("INTERLOCK_BYPASS", getSpindle(PART))));
  if (getProperty("usePartCatcher")) {
    writeBlock(mFormat.format(getCode("PART_CATCHER_ON", getSpindle(PART))));
    onDwell(1.1);
  }
  if (airCleanChuck) {
    writeBlock(mFormat.format(358), formatComment("AIR BLAST"));
  }
  clampChuck(spindle, UNCLAMP);

  if (getProperty("usePartCatcher")) {
    writeBlock(mFormat.format(getCode("PART_CATCHER_OFF", getSpindle(PART))));
    onDwell(1.1);
  }

  // clean out chips
  if (airCleanChuck) {
    writeBlock(mFormat.format(getCode("AIR_BLAST_ON", getSpindle(PART))));
    onDwell(2.5);
    writeBlock(mFormat.format(getCode("AIR_BLAST_OFF", getSpindle(PART))));
  }
  writeBlock(mFormat.format(getCode("STOP_SPINDLE", SPINDLE_SUB)));
  setCoolant(COOLANT_OFF);
  if (getProperty("optionalStop")) {
    onCommand(COMMAND_OPTIONAL_STOP);
    gMotionModal.reset();
  }
  writeComment(localize("END OF PART EJECT"));
  ejectRoutine = false;
}

function engagePartCatcher(engage) {
  if (getProperty("usePartCatcher")) {
    if (engage) { // engage part catcher
      writeBlock(mFormat.format(getCode("PART_CATCHER_ON", true)), formatComment(localize("PART CATCHER ON")));
    } else { // disengage part catcher
      onCommand(COMMAND_COOLANT_OFF);
      writeBlock(mFormat.format(getCode("PART_CATCHER_OFF", true)), formatComment(localize("PART CATCHER OFF")));
    }
  }
}

function onSectionEnd() {

  if (machineState.usePolarInterpolation) {
    setPolarInterpolation(false); // disable polar interpolation mode
  }

  if (isPolarModeActive()) {
    setPolarCoordinates(false); // disable Polar coordinates mode
  }

  if (getProperty("usePartCatcher") && partCutoff && currentSection.partCatcher) {
    engagePartCatcher(false);
  }
  if (partCutoff) {
    if (getProperty("controllerType") == "640MT") {
      writeBlock(gFormat.format(28), "U" + xFormat.format(0));
    } else {
      writeBlock(gFormat.format(53), "X" + xFormat.format(0));
    }
  }

  /*
  // Handled in start of onSection
  if (!isLastSection()) {
    if ((getLiveToolingMode(getNextSection()) < 0) && !currentSection.isPatterned() && (getLiveToolingMode(currentSection) >= 0)) {
      writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(PART))));
    }
  }
*/

  if (((getCurrentSectionId() + 1) >= getNumberOfSections()) ||
    (tool.number != getNextSection().getTool().number)) {
    onCommand(COMMAND_BREAK_CONTROL);
  }

  if (getSpindle(PART) == SPINDLE_SUB) {
    invertAxes(false, false);
  }

  /*
  // Handled in onSection
  if ((currentSection.getType() == TYPE_MILLING) &&
      (!hasNextSection() || (hasNextSection() && (getNextSection().getType() != TYPE_MILLING)))) {
    // exit milling mode
    if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
      // +Z
    } else if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, -1))) {
      // -Z
    } else {
      onCommand(COMMAND_STOP_SPINDLE);
    }
  }
*/

  forcePolarCoordinates = false;
  forcePolarInterpolation = false;
  partCutoff = false;
  forceAny();
}

function onClose() {

  var liveTool = getSpindle(TOOL) == SPINDLE_LIVE;
  optionalSection = false;
  onCommand(COMMAND_STOP_SPINDLE);
  setCoolant(COOLANT_OFF);

  writeln("");

  gMotionModal.reset();
  if (gotSecondarySpindle) {
    writeBlock(gMotionModal.format(0), gFormat.format(getProperty("controllerType") == "640MT" ? 28 : 53), barOutput.format(0)); // retract Sub Spindle if applicable
  }
  if (machineState.tailstockIsActive) {
    writeBlock(getCode("TAILSTOCK_OFF"));
    writeBlock(mFormat.format(32), formatComment("RETURN TAILSTOCK TO HOME POSITION"));
  }
  // Move to home position
  goHome();

  if (!getProperty("optimizeCAxisSelect")) {
    cAxisEngageModal.reset();
  }
  if (liveTool) {
    if (!machineState.stockTransferIsActive) {
      writeBlock(gFormat.format(getProperty("controllerType") == "640MT" ? 28 : 53), "H" + abcFormat.format(0)); // unwind
      cAxisEngageModal.reset();
      writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(PART))));
    }
  }

  // Automatically eject part
  if (ejectRoutine) {
    ejectPart();
  }

  writeln("");
  onImpliedCommand(COMMAND_END);
  if (getProperty("looping")) {
    //writeBlock(mFormat.format(54), formatComment(localize("Increment part counter"))); //increment part counter
    writeBlock(mFormat.format(99));
  } else {
    onCommand(COMMAND_OPEN_DOOR);
    writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
  }
  //writeln("%");
}

// <<<<< INCLUDED FROM ../common/mazak mill-turn.cps
properties.maximumSpindleSpeed.value = 4500;
