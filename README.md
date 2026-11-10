# 我的课程代码 · Computational Coursework

这里记录我在机器学习、数据分析、计算机视觉和计算机系统课程中做过的代码。既有从基础算法开始的实现，也有把多个工具连接成分析流程的练习。

我把不同课程放在各自的目录里。SVM、决策树和自训练保留了原来的核心实现；GDP 和牛脸项目则在原流程上重新组织了入口，具体改动见 [方法笔记](METHOD_NOTES.md)。

| 目录 | 我在这里练习什么 |
|---|---|
| `machine_learning/` | 从 SMO/RBF SVM、信息增益和增益率树，到 Bootstrap 集成与自训练；用 Iris 和 Digits 观察模型表现。 |
| `economic_data/` | 从 GDP 与人口构造指标，做对数变换、标准化和聚类；随代码提供的是虚构经济体示例。 |
| `vision/` | 用 ResNet50 提取牛脸特征，再用随机森林判断图片对是否属于同一头牛；先划分身份，再生成图片对。 |
| `database/` | 用学生、课程、选课三张表练习关系建模、主外键约束和关联查询。 |
| `riscv/` | 单周期 CPU 的 Verilog 模块与测试台；把计算机组成中的指令执行过程落实到模块连接。 |

机器学习实验和合成 GDP 示例可以直接运行，输出放在 `results/`。牛脸的完整训练、MySQL 执行和 CPU 仿真还没有在当前环境中重跑，各目录说明了对应的使用方式。

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

该命令会通过 torchvision 获取 ImageNet 预训练参数。仓库不分发图像、网络权重或训练后模型。这个版本还没有完成真实牛脸数据上的训练和评估。

## 实现与协作

牛脸、GDP 和 RISC-V 项目的代码由我编写或修改；部分课程是团队提交，我在这里展示代码，没有把团队报告作为个人独立完成的成果。

我使用 AI 辅助重构、评估入口和文档整理。公开版本中修正了部分数据划分与预处理问题：例如标准化要在训练数据上拟合，不能先对全部样本处理再划分测试集。这些改动与原作业的区别记录在方法笔记中。

运行环境、实验结果和仍未完成的检查放在 [运行记录](VALIDATION.md)。
