enum RunMode { debug, release }

const runMode = RunMode.debug;
const isDebugMode = runMode == RunMode.debug ? true : false;
const isReleaseMode = runMode == RunMode.release ? true : false;
