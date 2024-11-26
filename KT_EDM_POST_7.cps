/**
  Copyright (C) 2012-2022 by Autodesk, Inc.
  All rights reserved.

  AMADA post processor configuration.

  $Revision: 7 $
  $Date: 2022-05-05 14:10:48 $

  

 V0. Org Post Amanda laser 43797 b157ddfe2ebfe4ed20cf4d2babec16abcf9aa062

 V1. Added Ai settings
  Adc 2-22-2024

 V2. Added Passthrough

 V3. Added Auto fill/Drain option
  Adc 2-23-2024

 V4. Removed thickness options
  Adc 2-23-2024

 V5.Testing output of arc Switch "R" or "I" "J" "K"
  Need box active and conditional switch for output still
  need to fix 360 circles not outputting comp

 V6. Added tool number and offset output.
  Uses tool number As cut condition "S".
  Uses tool Diamiter as "D" from diamater table
  Adc 2-23-2024

 V7. Add taper Switch
  sets the M15 taper to a value of P0 zero  
  Adc 2-27-2024



*/

description = "KT Fanuc EDM";
vendor = "KINTECH";
vendorUrl = "http://www.amada.com";
legal = "Copyright (C) 2012-2022 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45702;

extension = "nc";
programNameIsInteger = true;
setCodePage("ascii");

capabilities = CAPABILITY_MILLING | CAPABILITY_JET;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = false;
allowedCircularPlanes = undefined; // allow any circular motion
highFeedrate = (unit == IN) ? 100 : 50;



// user-defined properties
properties = {
  showSequenceNumbers: {
    title      : "Use sequence numbers",
    description: "Use sequence numbers for each block of outputted code.",
    group      : "formats",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  sequenceNumberStart: {
    title      : "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group      : "formats",
    type       : "integer",
    value      : 10,
    scope      : "post"
  },
  sequenceNumberIncrement: {
    title      : "Sequence number increment",
    description: "The amount by which the sequence number is incremented by in each block.",
    group      : "formats",
    type       : "integer",
    value      : 5,
    scope      : "post"
  },
  useRetracts: {
    title      : "Use retracts",
    description: "Output retracts, otherwise only output part contours for importing into a third-party jet application.",
    group      : "homePositions",
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
  /*// V4.0 Adc 2-23-2024
  material: {
    title      : "Material type",
    description: "Specifies the material type for the M102 database call.",
    group      : "preferences",
    type       : "string",
    value      : "O-CRS0",
    scope      : "post"
  },
  materialThickness: {
    title      : "Material thickness",
    description: "Specifies the material thickness for the M102 database call.",
    group      : "preferences",
    type       : "string",
    value      : ".120",
    scope      : "post"
  },
  useStockForThickness: {
    title      : "Use stock for thickenss",
    description: "Specifies whether the stock thickness should be used for the M102 database call, instead of the 'use stock for thickness' property.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  */
  wcsX: {
    title      : "WCS X",
    description: "Sets the X WCS position.",
    group      : "homePositions",
    type       : "number",
    value      : 0,
    scope      : "post"
  },
  wcsY: {
    title      : "WCS Y",
    description: "Sets the Y WCS position.",
    group      : "homePositions",
    type       : "number",
    value      : 0,
    scope      : "post"
  },
   // V1. Added switch for ai code to be output in safe start 
   Use_AI: {
    title      : "Use Ai cutting on Funuc controller",
    description: "Enable to output AI cutting and Corner control",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  // V3. Added switch for auto fill/drain adc 2-23-2024
  Auto_Fill: {
    title      : "Use Auto fill and drain on Funuc controller",
    description: "Fills tank before cutting and drains at end of program",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  
  Output_Arc_R: {
    title      : "Output R value on arcs in Funuc controller",
    description: "Instead of i,j,k",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  Taper_Output: {
    title      : "Output No taper in Funuc controller",
    description: "Inserts M15 P0 at program start",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  }
};

var gFormat = createFormat({prefix:"G", decimals:0});
var mFormat = createFormat({prefix:"M", decimals:0});
var pFormat = createFormat({prefix:"P", decimals:0});

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4)});
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var feedFormat = createFormat({decimals: (unit == MM ? 2 : 3)});
var toolFormat = createFormat({decimals:0});
var rpmFormat = createFormat({decimals:0});
var powerFormat = createFormat({decimals:2});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-1000
var taperFormat = createFormat({decimals:1, scale:DEG});

// new vars for cicular action
var xOutput = createVariable({prefix:"X"}, xyzFormat);
var yOutput = createVariable({prefix:"Y"}, xyzFormat);
var zOutput = createVariable({onchange:function () {retracted = false;}, prefix:"Z"}, xyzFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, abcFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var sOutput = createVariable({prefix:"S", force:false}, rpmFormat);
var powerOutput = createVariable({prefix:"E", force:false}, powerFormat);
var numberOfToolSlots = 9999;

// circular output
 //orginal "R" output adc 2-23-2024
var rOutput = createVariable({prefix:"R", force:true}, xyzFormat);

//var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
//var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
//var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
//End here orginal "R"output adc 2-23-2024


// add circular funtions from kt_edm_post2
//Need to change R to I and J
var iOutput = createReferenceVariable({prefix:"I"}, xyzFormat);
var jOutput = createReferenceVariable({prefix:"J"}, xyzFormat);
var kOutput = createReferenceVariable({prefix:"K"}, xyzFormat);

var gMotionModal = createModal({force:true}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
// var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G93-94
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({}, gFormat); // modal group 9 // G81, ...
var gRetractModal = createModal({}, gFormat); // modal group 10 // G98-99



var WARNING_WORK_OFFSET = 0;

// collected state
var sequenceNumber;
var currentWorkOffset;
var split = false;
//var cutQuality;// removed adc-2-23-2024

//added for testing
var retracted = false; // specifies that the tool has been retracted to the safe plane


/**
  Writes the specified block.
*/
function writeBlock() {
  if (getProperty("showSequenceNumbers")) {
    writeWords2("N" + sequenceNumber, arguments);
    sequenceNumber += getProperty("sequenceNumberIncrement");
  } else {
    writeWords(arguments);
  }
}

function formatComment(text) {
  return "(" + String(text).replace(/[()]/g, "") + ")";
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text));
}

//Added Pass through in  ADC-1-8-24
//function onPassThrough(text) {
  //writeBlock(text);
//}

function onOpen() {

  
  if (!getProperty("separateWordsWithSpace")) {
    setWordSeparator("");
  }

  // Need to add to retract Button to turn off wtih retract selection
  if (!properties.useZ) {
    zOutput.disable();
  }

  //zOutput.disable();// remove if z output is needed

  if (true) {

    if (machineConfiguration) {
      setMachineConfiguration(machineConfiguration);
      optimizeMachineAngles2(1); // map tip mode
    }
  }

  sequenceNumber = getProperty("sequenceNumberStart");
  writeln("%");

  if (programName) {
    writeComment(programName);
  }
  if (programComment) {
    writeComment(programComment);
  }

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var description = machineConfiguration.getDescription();

  // dump tool information
  if (0) { // if (properties.writeTools)//V5.0 Changed this to be active {//if (properties.writeTool)
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
        var comment = "S" + toolFormat.format(tool.number) + " " +
          "D=" + xyzFormat.format(tool.diameter) + " " +
          localize("CR") + "=" + xyzFormat.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
        }
        if (zRanges[tool.number]) {
          comment += " - " + localize("ZMIN") + "=" + xyzFormat.format(zRanges[tool.number].getMinimum());
        }
        comment += " - " + getToolTypeName(tool.type);
        writeComment(comment);
      }
    }
  }

  // absolute coordinates and feed per min
  writeBlock(gAbsIncModal.format(90)/*, gFeedModeModal.format(94)*/);
  

   switch (unit) {
  case IN:
    writeBlock(gUnitModal.format(20));
    break;
  case MM:
    writeBlock(gUnitModal.format(21));
    break;
  }
  // Resets the timer for cutting duration
  writeBlock(mFormat.format(31));// resets timer adc 1-9-24
  //writeBlock(mFormat.format(86));// Machine conditions on adc 1-9-24

  // Auto fill switch Adc 2-23-2024
  if (getProperty("Auto_Fill")) {
    writeBlock(mFormat.format(85));// fill tank adc 1-9-24
  }

  // V1. addded Ai Codes at start up
  if (getProperty("Use_AI")) {
    writeBlock(mFormat.format(89));// AI controlled approach
    writeBlock(mFormat.format(27));// AI cornering
  }

  if (getProperty("Taper_Output")) {
    writeBlock(mFormat.format(15) + " " + pFormat.format(0) );// fill tank adc 1-9-24
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

/** Force output of X, Y, Z, and F on next output. */
function forceAny() {
  forceXYZ();
  feedOutput.reset();
}


var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function setWorkPlane(abc) {
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

  // NOTE: add retract here

  writeBlock(
    gMotionModal.format(0),
    conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(abc.x)),
    conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(abc.y)),
    conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(abc.z))
  );
  
  onCommand(COMMAND_LOCK_MULTI_AXIS);

  currentWorkPlaneABC = abc;
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane) {
  var W = workPlane; // map to global frame
 
  var abc = machineConfiguration.getABC(W);
  if (closestABC) {
    if (currentMachineABC) {
      abc = machineConfiguration.remapToABC(abc, currentMachineABC);
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  } else {
    abc = machineConfiguration.getPreferredABC(abc);
  }
  
  try {
    abc = machineConfiguration.remapABC(abc);
    currentMachineABC = abc;
  } catch (e) {
    error(
      localize("Machine angles not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }
  
  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize("Orientation not supported."));
  }
  
  if (!machineConfiguration.isABCSupported(abc)) {
    error(
      localize("Work plane is not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }

  var tcp = false;
  if (tcp) {
    setRotation(W); // TCP mode
  } else {
    var O = machineConfiguration.getOrientation(abc);
    var R = machineConfiguration.getRemainingOrientation(abc, W);
    setRotation(R);
  }
  
  return abc;
}
//Added Pass through in  ADC-1-8-24
function onPassThrough(text) {
  var commands = String(text).split(",");
  for (text in commands) {
    writeBlock(commands[text]);
  }
}

/** Returns the power for the given spindle speed.*/
function getPower() {
  switch (currentSection.jetMode) {
  case JET_MODE_THROUGH:
    return 0;
  case JET_MODE_ETCHING:
    return 0;
  case JET_MODE_VAPORIZE:
  default:
    error(localize("Laser cutting mode is not supported."));
  }
  return 0;
}

function isProbeOperation() {
  return (hasParameter("operation-strategy") &&
    getParameter("operation-strategy") == "probe");
}

function onSection() {
  var insertToolCall = isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number);

  retracted = false; // specifies that the tool has been retracted to the safe plane
  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() ||
  !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
  (currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
    Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
  (!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
  (!getPreviousSection().isMultiAxis() && currentSection.isMultiAxis() ||
    getPreviousSection().isMultiAxis() && !currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations
  if (insertToolCall || newWorkOffset || newWorkPlane) {
  
  // stop spindle before retract during tool change
  if (insertToolCall && !isFirstSection()) {
    onCommand(COMMAND_STOP_SPINDLE);
  }

  // retract to safe plane
  writeRetract(Z);
  zOutput.reset();
  }

  writeln("");

  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      writeComment(comment);
    }
  }

  //testing multi passes nneds fixed
  if (insertToolCall) {
  if (currentSection.type != TYPE_JET) {
    setCoolant(COOLANT_OFF);
      onCommand(COMMAND_STOP);

    if (tool.number > numberOfToolSlots) {
      warning(localize("Tool number exceeds maximum value."));
    }
   
    var showToolZMin = false;
    if (showToolZMin) {
      if (is3D()) {
        var numberOfSections = getNumberOfSections();
        var zRange = currentSection.getGlobalZRange();
        var number = tool.number;
        for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) {
          var section = getSection(i);
          if (section.getTool().number != number) {
            break;
          }
          zRange.expandToRange(section.getGlobalZRange());
        }
        writeComment(localize("ZMIN") + "=" + zRange.getMinimum());
       }
      }
    }
  }



  if (hasParameter("operation:machineQualityControl")) {  // check to see if quaility is manaul Feeds or automatic
    var qualityType = getParameter("operation:machineQualityControl");
    if (qualityType == "automatic") {
      auto = true;
    }
  }
 
   // onCommand(COMMAND_COOLANT_OFF);
   
  if (currentSection.type == TYPE_JET) {
    switch (tool.type) {
    case TOOL_LASER_CUTTER:
      break;
    default:
      error(localize("The CNC does not support the required tool."));
      return;
  }
  /* removed thickness optionadc 2-23-2024
  if (insertToolCall) {
    var materialThickness = undefined;
    if (getProperty("useStockForThickness")) {
      if (hasGlobalParameter("stock-lower-z") && hasGlobalParameter("stock-upper-z")) {
        materialThickness = xyzFormat.format(Math.abs(getGlobalParameter("stock-lower-z") - getGlobalParameter("stock-upper-z")));
      } else {
        materialThickness = getProperty("materialThickness");
      }
    } else {
      materialThickness = getProperty("materialThickness");
    }

    writeBlock(mFormat.format(102) + "(" + getProperty("material") + materialThickness + ")"); // material designation
    writeBlock(mFormat.format(100)); //Laser mode on
  }
  */

  switch (currentSection.jetMode) {
  case JET_MODE_THROUGH:
    //cutQuality = 1;// removed adc
    break;
  case JET_MODE_ETCHING:
    //cutQuality = 10;// removed adc
    break;
  case JET_MODE_VAPORIZE:
      break;
  default:
    error(localize("Unsupported cutting mode."));
    return;
  }

  //org switch ended here

  //writeBlock("E" + cutQuality); // cut condition select // removed adcc


  //writeComment("testing location");

  // V5.0 Testing tool number 

  writeBlock("S" + toolFormat.format(tool.number) + " " + ("D" + toolFormat.format(tool.diameterOffset)));
    if (tool.comment) {
      writeComment(tool.comment);
      }
    }
    if ((currentSection.type == TYPE_JET) &&
      (tool.type == TOOL_LASER_CUTTER)) {
    writeBlock(mFormat.format(86)); // activate 4 cut conditions adc 1-8-24
    }
  if ((currentSection.type != TYPE_JET) &&
      (insertToolCall ||
       isFirstSection() ||
       (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) ||
       (tool.clockwise != getPreviousSection().getTool().clockwise))) {
	if (currentSection.type != TYPE_JET) {
      if (spindleSpeed < 1) {
        error(localize("Spindle speed out of range."));
      }
      if (spindleSpeed > 99999) {
        warning(localize("Spindle speed exceeds maximum value."));
      }
    }
    if (!tool.clockwise) {
      error(localize("CNC does not support CCW spindle rotation."));
      return;
    }
    writeBlock(
      //sOutput.format(spindleSpeed), mFormat.format(tool.clockwise ? 3 : 4)
    );
  }

    writeBlock(gAbsIncModal.format(90), gFormat.format(92), xOutput.format(getProperty("wcsX")), yOutput.format(getProperty("wcsY")));


      
  /*
    // wcs
    if (insertToolCall) { // force work offset when changing tool
      currentWorkOffset = undefined;
    }
    var workOffset = currentSection.workOffset;
    if (workOffset == 0) {
      warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
      workOffset = 1;
    }
    if (workOffset > 0) {
      if (workOffset > 6) {
        error(localize("Work offset out of range."));
        return;
      } else {
        if (workOffset != currentWorkOffset) {
          writeBlock(gFormat.format(53 + workOffset)); // G54->G59
          currentWorkOffset = workOffset;
        }
      }
    }
  */

  forceXYZ();

  if (machineConfiguration.isMultiAxisConfiguration()) { // use 5-axis indexing for multi-axis mode
    // set working plane after datum shift

    var abc = new Vector(0, 0, 0);
    if (currentSection.isMultiAxis()) {
      forceWorkPlane();
      cancelTransformation();
    } else {
      abc = getWorkPlaneMachineABC(currentSection.workPlane);
    }
    setWorkPlane(abc);
  } else { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return;
    }
    setRotation(remaining);
  }

  // set coolant after we have positioned at Z
  //setCoolant(tool.coolant);
 
  forceAny();

  split = false;
  if (getProperty("useRetracts")) 
  {

  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  if (!retracted && !insertToolCall) {
    if (getCurrentPosition().z < initialPosition.z) {
      writeBlock(gMotionModal.format(1), zOutput.format(initialPosition.z));// removed 1
    }
  }

  //if (properties.useEDM_M3M5 &&
  //    (currentSection.type == TYPE_JET) &&
  //    (tool.type == TOOL_LASER_CUTTER)) {
  //  writeBlock(mFormat.format(86)); // activate laser// changed from 3 to 86 adc 1-8-24
  //}

    if (insertToolCall || retracted) {
    var lengthOffset = tool.lengthOffset;
    if (lengthOffset > numberOfToolSlots) {
      error(localize("Length offset out of range."));
      return;
    }

      // gMotionModal.reset();
      //writeBlock(gPlaneModal.format(17));

      if (!machineConfiguration.isHeadConfiguration()) {
        writeBlock(
          gAbsIncModal.format(90),
          gMotionModal.format(1), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y)
        );
       // writeBlock(gMotionModal.format(1), zOutput.format(initialPosition.z));// removed was out putting extra g1 line adc 2-27-2024
            } else {
        writeBlock(
          gAbsIncModal.format(90),
          gMotionModal.format(0),
          xOutput.format(initialPosition.x),
          yOutput.format(initialPosition.y),
          zOutput.format(initialPosition.z)//,
		      //feedOutput.format(highFeedrate)
        );
      }
      } else {
        writeBlock(
          gAbsIncModal.format(90),
          gMotionModal.format(0),
          xOutput.format(initialPosition.x),
          yOutput.format(initialPosition.y)//,
          //feedOutput.format(highFeedrate)
        );
      }
    } else {
     split = true;
  }

}

function onDwell(seconds) {
  if (seconds > 99999.999) {
    warning(localize("Dwelling time is out of range."));
  }
  seconds = clamp(0.001, seconds, 99999.999);
  writeBlock(gFormat.format(4), "S" + secFormat.format(seconds));
}

//function onSpindleSpeed(spindleSpeed) {
  // only for milling
  //writeBlock(sOutput.format(spindleSpeed));
//}

//function onCycle() {
  //writeBlock(gPlaneModal.format(17));
//}

function getCommonCycle(x, y, z, r) {
  forceXYZ();
  return [xOutput.format(x), yOutput.format(y),
    zOutput.format(z),
    "R" + xyzFormat.format(r)];
}

function onCyclePoint(x, y, z) {
  if (currentSection.type == TYPE_JET) {
    error(localize("Canned cycles are not allowed when using laser."));
	return;
  }
/*
  if (!properties.useCycles) {
    expandCyclePoint(x, y, z);
    return;
  }

  if (isFirstCyclePoint()) {
    repositionToCycleClearance(cycle, x, y, z);
    
    // return to initial Z which is clearance plane and set absolute mode

    var F = cycle.feedrate;
    var P = !cycle.dwell ? 0 : clamp(0.001, cycle.dwell, 99999.999); // in seconds

    switch (cycleType) {
    case "drilling":
      writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
        getCommonCycle(x, y, z, cycle.retract),
        feedOutput.format(F)
      );
      break;
    case "counter-boring":
      if (P > 0) {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(82),
          getCommonCycle(x, y, z, cycle.retract),
          "S" + secFormat.format(P), // not optional
          feedOutput.format(F)
        );
      } else {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
          getCommonCycle(x, y, z, cycle.retract),
          feedOutput.format(F)
        );
      }
      break;
    case "chip-breaking":
      expandCyclePoint(x, y, z);
      break;
    case "deep-drilling":
      if (P > 0) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(83),
          getCommonCycle(x, y, z, cycle.retract),
          "Q" + xyzFormat.format(cycle.incrementalDepth),
          feedOutput.format(F)
        );
      }
      break;
    default:
      expandCyclePoint(x, y, z);
    }
  } else {
    if (cycleExpanded) {
      expandCyclePoint(x, y, z);
    } else {
      var _x = xOutput.format(x);
      var _y = yOutput.format(y);
      if (!_x && !_y) {
        xOutput.reset(); // at least one axis is required
        _x = xOutput.format(x);
      }
      writeBlock(_x, _y);
    }
  }
}

*/
}
function onCycleEnd() {
  if (!cycleExpanded) {
    writeBlock(gCycleModal.format(80));
    zOutput.reset();
  }
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}
// org rapid funtion
  function onRapid(_x, _y, _z) {

  if (!getProperty("useRetracts") && ((movement == MOVEMENT_RAPID))) {
    doSplit();
    return;
  }

  if (split) {
    split = false;
    var start = getCurrentPosition();
    onExpandedRapid(start.x, start.y, start.z);
  }

}
var shapeArea = 0;
var shapePerimeter = 0;
var shapeSide = "inner";
var cuttingSequence = "";

function onParameter(name, value) {
  if ((name == "action") && (value == "pierce")) {
    // add delay if desired
  } else if (name == "shapeArea") {
    shapeArea = value;
  } else if (name == "shapePerimeter") {
    shapePerimeter = value;
  } else if (name == "shapeSide") {
    shapeSide = value;
  } else if (name == "beginSequence") {
    if (value == "piercing") {
      if (cuttingSequence != "piercing") {
        if (properties.allowHeadSwitches) {
          // Allow head to be switched here
        }
      }
    } else if (value == "cutting") {
      if (cuttingSequence == "piercing") {
        if (properties.allowHeadSwitches) {
          // Allow head to be switched here
        }
      }
    }
    cuttingSequence = value;
  }
}
/*
function onPower(power) {
  powerOutput.reset();
   writeBlock(powerOutput.format(power ? getPower() : 0));
}
*/
function onRapid(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    /*writeBlock(gMotionModal.format(1), x, y, z, feedOutput.format(highFeedrate), conditional(currentSection.type == TYPE_JET, powerOutput.format(0)));
     feedOutput.reset(); // org line changed to below
     */
    writeBlock(gMotionModal.format(1), x, y, z, conditional(currentSection.type == TYPE_JET));
     //feedOutput.reset();
  }
}

function onLinear(_x, _y, _z, feed) {
  
  if (!getProperty("useRetracts") && ((movement == MOVEMENT_RAPID))) {
    doSplit();
    return;
  }

  if (split) {
    resumeFromSplit(feed);
  }

  // at least one axis is required
  if (pendingRadiusCompensation >= 0) {
    // ensure that we end at desired position when compensation is turned off
    xOutput.reset();
    yOutput.reset();
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = feedOutput.format(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(gMotionModal.format(1), gFormat.format(41), x, y, conditional(auto = false)); //,f After false removed adc 2-26-2024
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(gMotionModal.format(1), gFormat.format(42), x, y, conditional(auto = false)); //,f After false removed
        break;
      default:
        writeBlock(gMotionModal.format(1), gFormat.format(40), x, y, conditional(auto = false)); //,f After false removed
      }
    } else {
      //writeBlock(gMotionModal.format(1), x, y, z, f, conditional(currentSection.type == TYPE_JET, powerOutput.format(power ? getPower() : 0)));
      writeBlock(gMotionModal.format(1), x, y, z);//,f removed
    }/*
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      feedOutput.reset(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f, conditional(currentSection.type == TYPE_JET));//, powerOutput.format(power ? getPower() : 0) aftertype_jet
    }*/
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  error(localize("The CNC does not support 5-axis simultaneous toolpath."));
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  error(localize("The CNC does not support 5-axis simultaneous toolpath."));
}

function doSplit() {
  if (!split) {
    split = true;
    gMotionModal.reset();
    xOutput.reset();
    yOutput.reset();
    feedOutput.reset();
  }
}

function resumeFromSplit(feed) {
  if (split) {
    split = false;
    var start = getCurrentPosition();
    var _pendingRadiusCompensation = pendingRadiusCompensation;
    pendingRadiusCompensation = -1;
    onExpandedLinear(start.x, start.y, start.z, feed);
    pendingRadiusCompensation = _pendingRadiusCompensation;
  }
}

/** Adjust final point to lie exactly on circle. */
function CircularData(_plane, _center, _end) {
  // use Output variables, since last point could have been adjusted if previous move was circular
  var start = new Vector(xOutput.getCurrent(), yOutput.getCurrent(), 0 /*zOutput.getCurrent()*/);
  var saveStart = new Vector(start.x, start.y, start.z);
  var center = new Vector(
    xyzFormat.getResultingValue(_center.x),
    xyzFormat.getResultingValue(_center.y),
    xyzFormat.getResultingValue(_center.z)
  );
  var end = new Vector(_end.x, _end.y, _end.z);
  switch (_plane) {
  case PLANE_XY:
    start.setZ(center.z);
    end.setZ(center.z);
    break;
  case PLANE_ZX:
    start.setY(center.y);
    end.setY(center.y);
    break;
  case PLANE_YZ:
    start.setX(center.x);
    end.setX(center.x);
    break;
  default:
    this.center = new Vector(_center.x, _center.y, _center.z);
    this.start = new Vector(start.x, start.y, start.z);
    this.end = new Vector(_end.x, _end.y, _end.z);
    this.offset = Vector.diff(center, start);
    this.radius = this.offset.length;
    break;
  }
  this.start = new Vector(
    xyzFormat.getResultingValue(start.x),
    xyzFormat.getResultingValue(start.y),
    xyzFormat.getResultingValue(start.z)
  );
  var temp = Vector.diff(center, start);
  this.offset = new Vector(
    xyzFormat.getResultingValue(temp.x),
    xyzFormat.getResultingValue(temp.y),
    xyzFormat.getResultingValue(temp.z)
  );
  this.center = Vector.sum(this.start, this.offset);
  this.radius = this.offset.length;

  temp = Vector.diff(end, center).normalized;
  this.end = new Vector(
    xyzFormat.getResultingValue(this.center.x + temp.x * this.radius),
    xyzFormat.getResultingValue(this.center.y + temp.y * this.radius),
    xyzFormat.getResultingValue(this.center.z + temp.z * this.radius)
  );

  switch (_plane) {
  case PLANE_XY:
    this.start.setZ(saveStart.z);
    this.end.setZ(_end.z);
    this.offset.setZ(0);
    break;
  case PLANE_ZX:
    this.start.setY(saveStart.y);
    this.end.setY(_end.y);
    this.offset.setY(0);
    break;
  case PLANE_YZ:
    this.start.setX(saveStart.x);
    this.end.setX(_end.x);
    this.offset.setX(0);
    break;
  }
}

/*
// Start R ARCS here
function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {

  if (!getProperty("useRetracts") && ((movement == MOVEMENT_RAPID) || (movement == MOVEMENT_HIGH_FEED))) {
    doSplit();
    return;
  }

  var circle = new CircularData(getCircularPlane(), new Vector(cx, cy, cz), new Vector(x, y, z));

  var r = circle.radius;
  if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
    r = -r; // allow up to <360 deg arcs
  }

  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  if (split) {
    resumeFromSplit(feed);
  }

  var start = circle.start;
  if (isFullCircle()) {
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(circle.end.x), rOutput.format(r), conditional(auto = false, feedOutput.format(feed)));
      break;
    default:
      linearize(tolerance);
    }
  } else {
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(circle.end.x), yOutput.format(circle.end.y), rOutput.format(r), conditional(auto = false, feedOutput.format(feed)));
      break;
    default:
      linearize(tolerance);
    }
  }
}
// END R ARCS here
*/

// ADDED I<J<K function ADC 2-26-2024

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  // one of X/Y and I/J are required and likewise
  
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0),  conditional(currentSection.type == TYPE_JET));
      gMotionModal.reset();
      break;
    case PLANE_ZX:
      writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0),  conditional(currentSection.type == TYPE_JET));
      gMotionModal.reset();
      break;
    case PLANE_YZ:
      writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), yOutput.format(y), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0),  conditional(currentSection.type == TYPE_JET));
      gMotionModal.reset();
      break;
    default:
      linearize(tolerance);
    }
  } else {
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), feedOutput.format(feed), conditional(currentSection.type == TYPE_JET));
      gMotionModal.reset();
      break;
    case PLANE_ZX:
      writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed), conditional(currentSection.type == TYPE_JET));
      gMotionModal.reset();
      break;
    case PLANE_YZ:
      writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed), conditional(currentSection.type == TYPE_JET));
      gMotionModal.reset();
      break;
    default:
      linearize(tolerance);
    }
  }
}
//end here new I,J,K circle out put testing


var mapCommand = {
  COMMAND_STOP         : 0,
  COMMAND_OPTIONAL_STOP: 1,
  COMMAND_END          : 2,
  COMMAND_SPINDLE_CLOCKWISE:3,
  COMMAND_STOP_SPINDLE:5
};

function onCommand(command) {
    switch (command) {
    case COMMAND_START_SPINDLE:
      if (!tool.clockwise) {
        error(localize("CNC does not support CCW spindle rotation."));
        return;
      }
      onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
      return;
    case COMMAND_POWER_ON:
      //writeBlock(mFormat.format(103) + (cutQuality == 10 ? " A0" : ""));//ORG line
      //writeBlock(mFormat.format(86));// turn on four conditions removed adc was adding extra m86 
      return;
    case COMMAND_POWER_OFF:
      //writeBlock(mFormat.format(104));// Org line
      writeBlock(mFormat.format(46));// turn off 4 conditions
      return;
    case COMMAND_COOLANT_ON:
      return;
    case COMMAND_COOLANT_OFF:
      return;
    case COMMAND_LOCK_MULTI_AXIS:
      return;
    case COMMAND_UNLOCK_MULTI_AXIS:
      return;
    case COMMAND_BREAK_CONTROL:
      return;
    case COMMAND_TOOL_MEASURE:
      return;
    }

    var stringId = getCommandStringId(command);
    var mcode = mapCommand[stringId];
    if (mcode != undefined) {
      writeBlock(mFormat.format(mcode));
  } else {
      onUnsupportedCommand(command);
    } 
}
  
function onSectionEnd() {
  //writeBlock(gPlaneModal.format(17)); // removed adc 
/*
if (properties.useEDM_M3M5 &&
      (currentSection.type == TYPE_JET) &&
      (tool.type == TOOL_LASER_CUTTER)) {
    writeBlock(mFormat.format(5)); // deactivate laser
}
*/
  forceAny();
}
/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
  if (arguments.length == 0) {
    error(localize("No axis specified for writeRetract()."));
    return;
  }
  var words = []; // store all retracted axes in an array
  for (var i = 0; i < arguments.length; ++i) {
    let instances = 0; // checks for duplicate retract calls
    for (var j = 0; j < arguments.length; ++j) {
      if (arguments[i] == arguments[j]) {
        ++instances;
      }
    }
    if (instances > 1) { // error if there are multiple retract calls for the same axis
      error(localize("Cannot retract the same axis twice in one line"));
      return;
    }
    switch (arguments[i]) {
    case X:
      words.push("X" + xyzFormat.format(machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : 0));
      break;
    case Y:
      words.push("Y" + xyzFormat.format(machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : 0));
      break;
    case Z:
      words.push("Z" + xyzFormat.format(machineConfiguration.getRetractPlane()));
      retracted = true; // specifies that the tool has been retracted to the safe plane
      break;
    default:
      error(localize("Bad axis specified for writeRetract()."));
      return;
    }
  }


  if (words.length > 0) {
    gMotionModal.reset();
    //gAbsIncModal.reset();// removed was adding extra g90 at end adc 1-9-24
    writeBlock(gAbsIncModal.format(90));
  }

  zOutput.reset();
}

function onClose() {

   writeRetract(Z);
    zOutput.reset();

  if (!machineConfiguration.hasHomePositionX() && !machineConfiguration.hasHomePositionY()) {
     writeRetract(X, Y);
  }

  // Auto fill switch Adc 2-23-2024
  if (getProperty("Auto_Fill")) {
    writeBlock(mFormat.format(45));// Drain tank adc 1-9-24
  }


  //writeBlock(mFormat.format(101)); // laser mode off
  //writeBlock(gFormat.format(50)); // return home
  writeBlock(mFormat.format(30)); // program end
  writeln("%");
}

function setProperty(property, value) {
  properties[property].current = value;
}

