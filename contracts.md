# Merlin 锁仓

## Ethereum 上的合约

### 锁仓合约

- [x] 在 Ethereum 上部署一个 Time Lock 锁仓合约，接受锁仓资金。到特定时间后才可解锁。解锁需要多签钱包完成。
- [ ] 问题：是否开通 Arbitrum / BNB Chain 到 Merlin 的锁仓通道？

### Meson 合约升级

- [x] 设置一个单独的 Ethereum -> Merlin L2 的跨链通道，跨链收到的资金，自动转入锁仓合约。


## Merlin 上的合约

### 标准 ETH/USDT/USDC

- [x] 用于发行标准的 *ETH/USDT/USDC token*
- [ ] 标准 ETH/USDT/USDC tokens 可以通过 Meson 跨链桥转出到 Ethereum 及其它链上（Meson来支持）

### Convertible ETH/USDT/USDC

- [x] 用于发行 *ConvertibleETH/USDT/USDC*，名为 USDT.c (Convertible Tether USD)
- [ ] 可以在Meson跨链时铸造
- [x] Convertible token可以在Merlin上流通，但是锁仓期间，不能转出
- [x] 该合约可以开启 *转换* 功能。锁仓期结束后，由管理员开启，即可转换成 *标准ETH/USDT/USDC*
- [ ] 管理员是个多签钱包
