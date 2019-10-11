const { exec } = require('child_process');
exec('pwsh -File portainer.ps1', (err, stdout, stderr) => {
  if (err) {
    console.error(`exec error: ${error}`);
    return;
  }
  console.log(`stdout: ${stdout}`);
  console.log(`stderr: ${stderr}`);
});