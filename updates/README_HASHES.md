# hashes.json 文件说明

## 如何计算 MSIX 文件的 SHA-256 哈希值

### Windows PowerShell
```powershell
Get-FileHash -Path "TodoCat-1.0.8-windows.msix" -Algorithm SHA256
```

### Windows CMD
```cmd
certutil -hashfile TodoCat-1.0.8-windows.msix SHA256
```

### Linux/Mac
```bash
shasum -a 256 TodoCat-1.0.8-windows.msix
# 或
sha256sum TodoCat-1.0.8-windows.msix
```

## 更新 hashes.json

1. 计算每个 MSIX 文件的 SHA-256 哈希值
2. 将哈希值更新到 `hashes.json` 文件中
3. 将 `hashes.json` 文件上传到与 `app-archive.json` 相同的目录（Gitee 和 GitHub）

## 文件位置

- Gitee: `https://gitee.com/dsxksss/TodoCat/raw/main/updates/hashes.json`
- GitHub: `https://raw.githubusercontent.com/dsxksss/TodoCat/refs/heads/main/updates/hashes.json`

## 注意事项

- 每次发布新版本时，需要更新 `hashes.json` 文件
- `desktop_updater` 会在 `app-archive.json` 的 URL 所在目录查找 `hashes.json`
- 如果使用单个文件链接，`hashes.json` 应该放在与 `app-archive.json` 相同的目录

