enum RunMode { debug, release }

const runMode = RunMode.release;
const isDebugMode = runMode == RunMode.debug ? true : false;
const isReleaseMode = runMode == RunMode.release ? true : false;
