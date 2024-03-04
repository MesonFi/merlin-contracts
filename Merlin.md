# Merlin

## BTC 资产

- 官方跨链桥将原生 BTC 跨到 Merlin 上
- Meson 可以提供中小额 BTC 的跨链能力
- 需要 Merlin 提供一些 Merlin 上的 BTC 作为初始流动性

用户累计交易后，meson 在不同链上的 BTC 余额会有变动。meson 使用官方桥来平衡流动性


## ETH 和稳定币资产

- 在 Ethereum 上需要设置一个锁仓合约，作为在 Merlin 上发行 ETH 和 Stablecoin 的担保
- Merlin 上有一个 mint 合约，用于 mint/burn ETH 及 Stablecoin
- 官方 pre-mint 一批 ETH 和稳定币，借给 meson 作为初始流动性
- 如果有大户来交易，单笔超过 Merlin 上的已有流动性，需要继续 pre-mint 来完成交易

用户累计交易后，meson 在不同链上余额会有变动。需要平衡流动性：

向 Merlin 转入
- 将 ETH 或稳定币转入锁仓合约
- 基于锁仓合约，在 Merlin 上增发对应数量的 ETH 或稳定币

从 Merlin 转出
- 在 Merlin 上销毁 ETH 或稳定币
- 基于销毁，从锁仓合约中解锁一定量的 ETH 或稳定币

## 安全

将绝大数资金集中在锁仓合约中。Meson 合约中保持一定的流动性，足够用户进行兑换即可

### 锁仓合约

被盗将导致锁仓资金损失

安全处理
- 多签
- 出金会有延迟（24h）
- 可冻结出金

### mint 合约

如被盗，黑客可以大量 mint 没有抵押的 token，然后通过 meson 换取其他链上有价值的 token

安全处理
- 多签
- meson 对换出有金额限制，不影响中小额交易，但大额资金无法一次性转出
- 如果出现集中转出，将暂停兑换，等待人工确认
- 对于大额转出的需求（>20k），需要提前预约，并且转出过程需要等待更长时间（24h 以上）

### 长期方案

保留未来升级的可能性，将 lock-mint 机制升级成更安全可靠的方案。


## 合约具体方案

### 锁仓合约

锁仓合约是一个可升级合约，有如下若干操作权限

- minter：拥有unlock/withdraw的权限，为一个多签地址
- freeze keys：一系列只能使用一次的可以冻结合约的key（合约中存储若干 `hash(key)`）
- admin：拥有合约的一些管理权限，为一个多签地址
- root：拥有升级合约的权限

**主要合约方法**

- `lock` (任何人均可调用): 向合约内转入一定量资金（ETH 或稳定币）进行锁仓；
- `unlock` (minter、未冻结): 从合约内解锁一定量资金，解锁资金需要等待 24h（待定）才可取出。取出资金的收款地址需要此时确定；
- `withdraw` (minter、未冻结): 对于之前已经解锁，并完成等待的资金，从合约内取出至指定地址；
- `cancel` (minter 或 admin): 取消一笔解锁资金；
- `freeze` (freeze key): 将合约处于冻结状态，任何提款交易都不可进行；
- `unfreeze` (root): 恢复合约的冻结状态；
- `addWhitelistAddr` (admin、未冻结): 设置白名单地址（unlock无需等待）。修改后合约将自动进入freeze状态，需要解锁；
- `transferMinter` (admin): 更改 minter 权限的所有者。transfer后合约将自动进入freeze状态，需要解锁；
- `upgradeTo` (root、未冻结): 升级合约。

**使用场景**

日常使用 minter 权限进行 unlock/withdraw 操作；
遇到问题时，使用freeze keys对合约进行锁定，以便后续检查各权限是否安全；
使用 admin 权限修改白名单，或者修改 minter 权限；平时应避免使用 admin 权限；
在特殊情况下，需要 root 来 unfreeze 合约或者升级合约；root 有最高权限，应严格保管。

**权限管理**

- minter：2/3多签地址，三方各管理一个私钥
- admin：2/3多签地址，三方各管理一个私钥；与上述私钥不重合
- root：3/4多签地址，三方各管理一个私钥，第四个私钥使用MPC wallet；与上述私钥不重合

### mint合约

mint合约是一个可升级合约，有如下若干操作权限

- minter：拥有mint的权限，为一个多签地址
- freeze keys：一系列只能使用一次的可以冻结合约的key（合约中存储若干 `hash(key)`）
- root：拥有升级合约的权限

**主要合约方法**

- `burn` (任何人均可调用): 向合约内转入一定量资金（ETH 或稳定币）进行销毁；
- `mint` (minter、未冻结): mint增发一定量新token；
- `freeze` (freeze key): 将合约处于冻结状态，任何提款交易都不可进行；
- `unfreeze` (root): 恢复合约的冻结状态；
- `upgradeTo` (root、未冻结): 升级合约。

**使用场景**

日常使用 minter 权限进行 mint 操作；
遇到问题时，使用freeze keys对合约进行锁定，以便后续检查各权限是否安全；
在特殊情况下，需要 root 来 unfreeze 合约或者升级合约；root 有最高权限，应严格保管。

**权限管理**

- minter：2/3多签地址，三方各管理一个私钥
- root：3/4多签地址，三方各管理一个私钥，第四个私钥使用MPC wallet；与上述私钥不重合
