# MD-11 Master System
# Copyright (c) 2020 Josh Davidson (Octal450)

var FCTL = {
	Fail: {
		elevatorFeel: props.globals.getNode("/systems/failures/fctl/elevator-feel"),
		flapLimit: props.globals.getNode("/systems/failures/fctl/flap-limit"),
		lsasLeftIn: props.globals.getNode("/systems/failures/fctl/lsas-left-in"),
		lsasLeftOut: props.globals.getNode("/systems/failures/fctl/lsas-left-out"),
		lsasRightIn: props.globals.getNode("/systems/failures/fctl/lsas-right-in"),
		lsasRightOut: props.globals.getNode("/systems/failures/fctl/lsas-right-out"),
		ydUpperA: props.globals.getNode("/systems/failures/fctl/yd-upper-a"),
		ydUpperB: props.globals.getNode("/systems/failures/fctl/yd-upper-b"),
		ydLowerA: props.globals.getNode("/systems/failures/fctl/yd-lower-a"),
		ydLowerB: props.globals.getNode("/systems/failures/fctl/yd-lower-b"),
	},
	Lsas: {
		leftInActive: props.globals.getNode("/fdm/jsbsim/fcc/lsas/left-in-active", 1),
		leftOutActive: props.globals.getNode("/fdm/jsbsim/fcc/lsas/left-out-active", 1),
		RightInActive: props.globals.getNode("/fdm/jsbsim/fcc/lsas/right-in-active", 1),
		RightOutActive: props.globals.getNode("/fdm/jsbsim/fcc/lsas/right-out-active", 1),
	},
	Switch: {
		elevatorFeelKnob: props.globals.getNode("/controls/fctl/elevator-feel-knob"),
		elevatorFeelMan: props.globals.getNode("/controls/fctl/elevator-feel-man"),
		flapLimit: props.globals.getNode("/controls/fctl/flap-limit-knob"),
		lsasLeftIn: props.globals.getNode("/controls/fctl/lsas-left-in"),
		lsasLeftOut: props.globals.getNode("/controls/fctl/lsas-left-out"),
		lsasRightIn: props.globals.getNode("/controls/fctl/lsas-right-in"),
		lsasRightOut: props.globals.getNode("/controls/fctl/lsas-right-out"),
		ydUpperA: props.globals.getNode("/controls/fctl/yd-upper-a"),
		ydUpperB: props.globals.getNode("/controls/fctl/yd-upper-b"),
		ydLowerA: props.globals.getNode("/controls/fctl/yd-lower-a"),
		ydLowerB: props.globals.getNode("/controls/fctl/yd-lower-b"),
	},
	init: func() {
		me.resetFail();
		me.Switch.elevatorFeelKnob.setValue(0);
		me.Switch.elevatorFeelMan.setBoolValue(0);
		me.Switch.flapLimit.setValue(0);
		me.Switch.lsasLeftIn.setBoolValue(1);
		me.Switch.lsasLeftOut.setBoolValue(1);
		me.Switch.lsasRightIn.setBoolValue(1);
		me.Switch.lsasRightOut.setBoolValue(1);
		me.Switch.ydUpperA.setBoolValue(1);
		me.Switch.ydUpperB.setBoolValue(1);	
		me.Switch.ydLowerA.setBoolValue(1);
		me.Switch.ydLowerB.setBoolValue(1);
	},
	resetFail: func() {
		me.Fail.elevatorFeel.setBoolValue(0);
		me.Fail.flapLimit.setBoolValue(0);
		me.Fail.lsasLeftIn.setBoolValue(0);
		me.Fail.lsasLeftOut.setBoolValue(0);
		me.Fail.lsasRightIn.setBoolValue(0);
		me.Fail.lsasRightOut.setBoolValue(0);
		me.Fail.ydUpperA.setBoolValue(0);
		me.Fail.ydUpperB.setBoolValue(0);	
		me.Fail.ydLowerA.setBoolValue(0);
		me.Fail.ydLowerB.setBoolValue(0);
	},
};

var FADEC = {
	eng1Powered: props.globals.getNode("/fdm/jsbsim/fadec/eng-1-powered"),
	eng2Powered: props.globals.getNode("/fdm/jsbsim/fadec/eng-2-powered"),
	eng3Powered: props.globals.getNode("/fdm/jsbsim/fadec/eng-3-powered"),
	pitchMode: 0,
	Limit: {
		active: props.globals.getNode("/fdm/jsbsim/fadec/limit/active"),
		activeMode: props.globals.getNode("/fdm/jsbsim/fadec/limit/active-mode"),
		activeModeInt: props.globals.getNode("/fdm/jsbsim/fadec/limit/active-mode-int"), # 0 T/O, 1 G/A, 2 MCT, 3 CLB, 4 CRZ
		cruise: props.globals.getNode("/fdm/jsbsim/fadec/limit/cruise"),
		climb: props.globals.getNode("/fdm/jsbsim/fadec/limit/climb"),
		goAround: props.globals.getNode("/fdm/jsbsim/fadec/limit/go-around"),
		mct: props.globals.getNode("/fdm/jsbsim/fadec/limit/mct"),
		takeoff: props.globals.getNode("/fdm/jsbsim/fadec/limit/takeoff"),
	},
	Switch: {
		eng1Altn: props.globals.getNode("/controls/fadec/eng-1-altn"),
		eng2Altn: props.globals.getNode("/controls/fadec/eng-2-altn"),
		eng3Altn: props.globals.getNode("/controls/fadec/eng-3-altn"),
	},
	init: func() {
		me.Limit.activeMode.setValue("T/O");
	},
	loop: func() {
		me.pitchMode = afs.Text.vert.getValue();
		if (me.pitchMode == "G/A CLB") {
			me.Limit.activeModeInt.setValue(1);
			me.Limit.activeMode.setValue("G/A");
			me.Limit.active.setValue(me.Limit.goAround.getValue());
		} else if (me.pitchMode == "T/O CLB") {
			me.Limit.activeModeInt.setValue(0);
			me.Limit.activeMode.setValue("T/O");
			me.Limit.active.setValue(me.Limit.takeoff.getValue());
		} else if (me.pitchMode == "SPD CLB" or (me.pitchMode == "V/S" and afs.Input.vs.getValue() >= 50) or pts.Controls.Flight.flapsInput.getValue() >= 2) {
			me.Limit.activeModeInt.setValue(3);
			me.Limit.activeMode.setValue("CLB");
			me.Limit.active.setValue(me.Limit.climb.getValue());
		} else {
			me.Limit.activeModeInt.setValue(4);
			me.Limit.activeMode.setValue("CRZ");
			me.Limit.active.setValue(me.Limit.cruise.getValue());
		}
	},
};