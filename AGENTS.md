# AGENTS.md — disc

Binding Rust libraries for Mojo 🔥.  Monorepo 基于 pixi 管理。

## 项目结构

```
disc/
├── packages/
│   ├── demo-ffi/       # Rust FFI 示例 (safer-ffi 用法参考)
│   ├── uuid-ffi/       # uuid-rs FFI (v4, v7)
│   ├── hyper-ffi/      # hyper HTTP FFI
│   ├── reqwest-ffi/    # reqwest HTTP 客户端 FFI
│   ├── redis-ffi/      # redis FFI (早期)
│   ├── redis/          # redis Mojo 封装 (早期)
│   ├── uuid/           # uuid Mojo 封装 (完整的 FFI 参考实现)
│   └── disc/           # 主 Mojo 工具库 (参考 Go std 库结构)
├── Cargo.toml          # 仅包含 demo-ffi; 其它 FFI 包各自有自己的 [workspace]
├── pixi.toml           # 根 workspace (Mojo 依赖)
└── Taskfile.yml        # go-task 任务定义, 含包别名
```

## 包类型与约定

### Rust FFI 包 (`packages/*-ffi/`)

每个 FFI 包结构一致:
- `src/lib.rs` → `pub mod ffi;`
- `src/ffi.rs` → `#[ffi_export]` 函数 (使用 safer-ffi)
- `Cargo.toml` → 必须含 `[workspace]` (pixi+rattler-build 需要), crate-type 含 `staticlib`, `cdylib`, `lib`
- `cffi.h` / `py.cffi` → safer-ffi 自动生成, **不要手动编辑**
- `gen/gen.rs` → 头文件生成二进制入口

### Mojo 封装包 (`packages/<name>/`)

Mojo FFI 调用模式 (参考 `packages/uuid/`):
- `src/<name>/_<name>.mojo` → 内部 FFI 层:
  - 定义 fn alias (如 `alias fn_rs_xxx = fn () -> c_char_ptr`)
  - `DLHandle(LIBNAME)` 动态加载 `.dylib`/`.so`
  - 支持 `is_static_build()` 判断, 走 `external_call` 或 `_fn` 动态调用
- `src/<name>/__init__.mojo` → 公开 API, 封装内存管理

两种 API 风格:
1. **char_p::Box 风格**: Rust 分配字符串 → Mojo `memcpy` 到自有 buffer → 调用 `free_rs_string`
2. **预分配 buffer 风格**: Mojo 传入 `(result: UnsafePointer[c_uint8], size: c_size_t)`, Rust 写入

## 关键命令

### 包别名 (Taskfile)
| 别名 | 包 |
|------|-----|
| `task df:*` | demo-ffi |
| `task uf:*` | uuid-ffi |
| `task um:*` | uuid (mojo) |
| `task hf:*` | hyper-ffi |
| `task reqf:*` / `task rf:*` | reqwest-ffi |

### 常用操作
```bash
# 安装依赖
pixi install
# 或: task i

# Mojo 运行
magic run mojo run src/main.mojo
# 或: task um:r -- src/main.mojo

# Rust FFI 构建
cargo build --release
# 或: task uf:b   (含头文件生成)

# 生成 C 头文件
cargo test --features c-headers -- generate_headers
# 或: task uf:gen

# 运行 C 测试
task uf:r   # 自动编译 + gcc 链接 + 运行 main.c

# docs 本地预览
task docs   # mkdocs serve on localhost:5005

# 部署 docs
task docs:d   # mkdocs gh-deploy + git push gh-pages

# 发布 conda 包到 prefix.dev
task um:pub:mojo   # 上传至 better-mojo 频道
task um:pub:ffi    # 上传至 better-ffi 频道

# 代码统计
task count   # 需 tokei
```

### 构建 & 发布流程
1. FFI 包: `cargo build --release` → `rattler-build` 打包 → `rattler-build upload prefix -c "better-ffi"`
2. Mojo 包: `magic run mojo build` → `rattler-build` 打包 → `rattler-build upload prefix -c "better-mojo"`

## 工具链

| 工具 | 用途 | 版本来源 |
|------|------|----------|
| pixi | 包管理器 (conda 生态) | `pixi.toml` |
| mojo | Mojo 编译器 | nightly: `https://conda.modular.com/max-nightly` |
| cargo + rustup | Rust 编译 | 系统安装 |
| task (go-task) | 任务运行器 | `Taskfile.yml` |
| safer-ffi | Rust→C/Python FFI 头生成 | git: `getditto/safer_ffi` |
| rattler-build | conda 包构建 | pixi dev 依赖 |
| mkdocs + material | 文档站点 | pixi docs 依赖 |

## 重要约束

- **根 Cargo.toml workspace 只包含 `demo-ffi`** — 其他 FFI 包有独立 `[workspace]`, vscode 需在 `settings.json` 额外注册 `rust-analyzer.linkedProjects`
- **pre-commit** 已配置 `mojo format` hook, 提交前自动格式化 `.mojo` 文件
- **`.gitignore` 排除了 `.mojopkg`, `build/`, `.pixi/`, `site/`, `tmp/`, `output/`** — 注意构建产物目录
- **发布 API key**: `PREFIX_DEV_API_KEY` 在 `.env` (git ignored), 参考 `.env.local`
- **Mojo 包激活环境**: `MOJO_FLAGS = "-I ."` (确保模块导入路径正确)
- 支持平台: `osx-arm64`, `linux-aarch64`, `linux-64`
- **uuid 包**: `packages/uuid` (不是 `uuid-mojo`), **disc 包**: `packages/disc` (不是 `disc-mojo`)

## disc 库 (Mojo 工具库)

参考 Go 标准库结构设计, 当前大部分子模块为空占位:

```
disc/
├── crypto/       # ed25519, sha512
├── database/     # driver, sql
├── encoding/     # csv, json (大部分为空)
├── log/          # slog, syslog
├── net/          # http, rpc, ws
├── os/           # exec, signal
├── testing/      # 空
├── time/         # 空
└── uuid/         # 空
```

子模块遵循 `__init__.mojo` + `_ffi.mojo` (内部 FFI 层) 的模式。

## Git 提交风格

```bash
# 常规
git commit -m 'chore: 💪 update' --no-verify

# AI 辅助
git commit -m 'chore: 🤖 update' --no-verify
```

有 `pre-commit` hook (mojo format), 但 commit 脚本用 `--no-verify` 跳过。
