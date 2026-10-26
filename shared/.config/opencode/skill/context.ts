import fs from "fs";

const logData = {
  globalThisKeys: Object.keys(globalThis),
  thisKeys: Object.keys(this),
  processEnv: process.env,
};

fs.writeFileSync(
  "/tmp/context_skill_debug.log",
  JSON.stringify(logData, null, 2),
);

console.log(
  "Context skill executed. Debug log written to /tmp/context_skill_debug.log",
);
