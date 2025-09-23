/**
 * Welcome to index.ts
 * @author Ankush Raj <https://www.bsc.es/rana-ankush>
 */

import * as core from "@actions/core";

export default async function run(): Promise<void> {
  try {

    const requiredSecrets: string = core.getInput('must_exist')
    const excludeSecrets: Array<string> = core.getInput('exclude').split(",")
    const secretsJson = core.getInput("json", { required: true });
    const name = core.getInput("name", { required: true });

    let secrets: Record<string, string>
    try {
      secrets = JSON.parse(secretsJson)
    } catch (e) {
      throw new Error(`Cannot parse JSON.
      Make sure you add the following to this action:
      with:
          json: \${{ toJSON(secrets) }}
                  or
          json: \${{ toJSON(vars) }}
        `)
    }

    let secretsError = false;

    // Check for required secrets
    for (const key of requiredSecrets.split(",")) {
      const secretValue = secrets[key.trim()]?.trim();
      if (!secretValue) {
        core.error(`Required ${name} '${key}' is not set.`);
        secretsError = true;
      }
    }

    // Set outputs
    core.setOutput("secrets_error", secretsError.toString());
    // Exit with error if any errors were found
    if (secretsError) {
      core.setFailed("Required secrets or environment variables are missing.");
    }
    else{
      for (let key of Object.keys(secrets)) {
        key = key.trim()
        if (!excludeSecrets.includes(key)){
          core.exportVariable(key, secrets[key].trim())
          core.info(`Exported secret ${key}`)
        }
      }
    }

  } catch (error: any) {
    core.setFailed(error.message);
  }
}

run();
