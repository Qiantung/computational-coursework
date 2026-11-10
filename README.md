# Computational Coursework

精选课程项目：从算法实现、经济数据分析到视觉与计算机系统。将可讲解、能复查的课程工作集中管理，作为个人学习与研究准备的补充展示。

| 模块 | 展示内容 | 本次验证范围 |
|---|---|---|
| `machine_learning/` | 手写 SMO/RBF SVM、多分类；信息增益/增益率树；Bootstrap 集成；自训练 | Iris、Digits 实际运行，结果见 `results/` |
| `economic_data/` | GDP 指标检查、对数变换、标准化、K-means 与轮廓系数 | 30 个虚构经济体的合成示例实际运行 |
| `vision/` | ResNet50 特征差 + 随机森林牛脸配对验证 | 身份划分/配对逻辑检查；完整图像训练未重跑 |
| `database/` | MySQL 学生、课程、选课关系模型与查询 | 结构检查；本次未连接 MySQL |
| `riscv/` | 单周期处理器模块与原测试台 | 文件/模块结构检查；本次未运行 Vivado 仿真 |

## 快速运行

Python 3.12，在仓库根目录执行：

```bash
python -m pip install -r requirements.txt
python -m machine_learning.run svm --output results/local/svm.json
python -m machine_learning.run trees --output results/local/trees.json
python -m machine_learning.run semi --output results/local/semi.json
python economic_data/gdp_analysis.py --input economic_data/synthetic_gdp.csv --output results/local/gdp
python -m unittest discover -s tests
```

Iris 与 Digits 由 scikit-learn 提供，无需原始课程数据。合成 GDP CSV 不是世界银行、联合国或真实国家数据。GDP 分组仅为描述性探索，不能解释为经济发展排名或因果关系。

牛脸模型另需 `pip install -r requirements-vision.txt`，输入目录组织为 `root/identity/image.jpg`，然后执行：

```bash
python vision/cowface.py --images /path/to/authorized/images --output results/local/cowface.json
```

该命令会通过 torchvision 获取 ImageNet 预训练参数。仓库不分发图像、网络权重或训练后模型。尚未运行真实牛脸数据，不提供准确率承诺。

## 评估与整理说明

本次发布保留原 SVM、决策树与自训练核心代码，新增独立、固定随机种子的评估入口；GDP 与牛脸部分为原流程的发布版重构。原材料与发布版的差异详见 [METHOD_NOTES.md](METHOD_NOTES.md)。代码整理、验证入口与说明有 AI 辅助，不把这些改动描述为历史课程作业已经具备的功能。

课程资料包含团队提交版本。作者确认本次选取的牛脸、GDP、RISC-V 代码由本人编写/修改；团队报告不作为个人独立完成的成果发布。其他同学目录、课件、试题与教材没有纳入仓库。

该仓库是教学与学习记录。需要申请科研时，建议结合一个具体模块讲清问题、实现、验证过程及局限，而不以仓库数量作为成果质量依据。
