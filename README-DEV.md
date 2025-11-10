### MSIX 包签名说明

**为什么需要证书？**

Windows 要求所有 MSIX 包必须经过数字签名才能安装，这是 Windows 的安全要求。未签名的 MSIX 包无法安装。

**解决方案：**

#### 方案 1：创建自签名证书（用于测试/开发）

1. **创建自签名证书**（使用 PowerShell）：
```powershell
# 创建自签名证书（有效期 10 年）
New-SelfSignedCertificate -Type CodeSigningCert -Subject "CN=SayMiao" -KeyUsage DigitalSignature -FriendlyName "TodoCat Code Signing" -CertStoreLocation "Cert:\CurrentUser\My" -NotAfter (Get-Date).AddYears(10)

# 导出为 .pfx 文件（需要设置密码）
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -eq "CN=SayMiao"}
$password = Read-Host -AsSecureString -Prompt "输入证书密码"
Export-PfxCertificate -Cert $cert -FilePath ".\TodoCat.pfx" -Password $password
```

2. **配置证书路径**：
   在 `pubspec.yaml` 文件的 `msix_config` 段中配置证书路径：
```yaml
msix_config:
  display_name: TodoCat
  publisher_display_name: SayMiao
  identity_name: SayMiao.TodoCat
  msix_version: 1.0.9.0
  logo_path: windows/runner/resources/app_icon.ico
  capabilities: internetClient, location, microphone, webcam
#   certificate_path: "path/to/TodoCat.pfx"  # 证书文件路径
#   certificate_password: "你的证书密码"  # 证书密码
  这里使用打包的自签名证书
```

3. **安装证书到受信任的根证书颁发机构**（仅自签名证书需要）：
   - 双击 `.pfx` 文件，按提示安装证书
   - 或在 PowerShell 中运行：
```powershell
Import-PfxCertificate -FilePath ".\TodoCat.pfx" -CertStoreLocation "Cert:\LocalMachine\Root" -Password (Read-Host -AsSecureString -Prompt "输入证书密码")
```

#### 方案 2：使用商业代码签名证书（用于生产环境）

1. 从受信任的证书颁发机构（如 DigiCert、Sectigo 等）购买代码签名证书
2. 将证书导出为 `.pfx` 格式
3. 在 `pubspec.yaml` 的 `msix_config` 段中配置证书路径和密码

**注意：**
- 自签名证书仅适用于测试和开发环境
- 生产环境建议使用受信任的证书颁发机构颁发的证书
- 如果使用自签名证书，用户需要先安装证书到受信任的根证书颁发机构才能安装 MSIX 包