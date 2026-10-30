# dsh-session-notes

两个 Agent Skill：让会话里的提问变成可检索的索引，再变成你笔记库里的 Markdown。

| Skill | 触发 | 作用 |
|---|---|---|
| `list-questions` | `/list`、`/list 关键词` | 把本次会话中问过的问题整理成一张编号表格 |
| `conclude` | `/conclude [序号] [地址]` | 把指定问答整理成 Markdown，存进你的笔记库 |

两者可以单独安装、单独使用；配合起来最顺——`/list` 负责编号，`/conclude` 按编号取件。

## 安装

### 一键脚本

Windows（PowerShell）：

```powershell
git clone https://github.com/lidengbo/dsh-session-notes.git
cd dsh-session-notes
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

> 很多 Windows 机器默认执行策略是 `Restricted`，直接 `.\install.ps1` 会报“禁止运行脚本”。上面这条用 `-ExecutionPolicy Bypass` 只对这一次生效，不改系统设置。

macOS / Linux：

```bash
git clone https://github.com/lidengbo/dsh-session-notes.git
cd dsh-session-notes
./install.sh
```

脚本会把 `skills/` 下的每个目录复制到 `~/.agents/skills/`。加 `-Claude`（PowerShell）或 `--claude`（bash）可同时装到 `~/.claude/skills/`。

### 手动安装

任何一个 skill 就是一个目录 + 一个 `SKILL.md`。把 `skills/list-questions/` 和 `skills/conclude/` 整个复制到你的 skills 目录即可：

- DSH / Codex 风格：`~/.agents/skills/`
- Claude Code：`~/.claude/skills/`

目录名必须和 `SKILL.md` 里 `name:` 一致。

## 用起来是什么样

```
你：/list
AI：| # | 问题 |
    |---|---|
    | Q1 | Rust 的所有权检查在编译期怎么实现 |
    | Q2 | 为什么 async 里不能直接 await 一个 MutexGuard |
    共 2 问

你：/conclude 2
AI：已存：D:\vault\为什么 async 里不能直接 await 一个 MutexGuard.md（980 字）
```

`/conclude` 省略序号时直接取最后一个真问题，不要求先跑 `/list`；给了序号才以最近一次 `/list` 的表为准，本会话没出过表就按同一套规则临时重建并说明一句。

### 参数写法

| 输入 | 结果 |
|---|---|
| `/conclude` | 存最后一个「真问题」 |
| `/conclude 3` | 存 Q3 |
| `/conclude 1,3,5` 或 `/conclude 1-3` | 分开存成多篇 |
| `/conclude 6 7 8` | 合并整合成一篇 |
| `/conclude 3 我的笔记` | 存到 `<仓库>/我的笔记/` |
| `/conclude "D:\notes\学习"` | 直接存到该绝对路径 |

## 必须先改的一处配置

打开 `skills/conclude/SKILL.md`，把这一行的占位符换成你的笔记库绝对路径：

```
默认仓库：`<在这里填写你的笔记库绝对路径，例如 D:\obsidian-vault>`
```

不填也能用——只是每次都得在命令里带上地址，否则它会反问你存哪儿，而不是猜一个路径。

## 设计说明

为什么是两个 skill 而不是一个：

- 触发靠 `description`。合成一个文件后，两个触发词挤在一条描述里，模型更容易认错。
- 成本不同。`/list` 只是排版，`/conclude` 要读一整套写作规范。分开装，简单的那个不会拖着 12KB 上下文。
- 可以只装一个。

那它们怎么保持"一块用"？靠约定，不靠代码耦合：`conclude` 只在用户给了序号时才引用 `/list` 的表，并且自带一份同规则的回退实现。所以不跑 `/list`、顺序反了，都不会崩。

## 目录结构

```
.
├── skills/
│   ├── list-questions/SKILL.md
│   └── conclude/SKILL.md
├── install.ps1
├── install.sh
├── LICENSE
└── README.md
```

## 关于标记

`conclude` 在整理回答时，会保留原回答里已有的 `[已验证]` / `[未验证]` / `[推测]` 标记。这套标记来自作者的使用习惯（已验证 = 实际跑过或查过原始出处；未验证 = 有依据没验证；推测 = 纯推断），你可以忽略，也可以在自己的 `AGENTS.md` 里定义一套。

## License

MIT
