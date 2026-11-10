-- MySQL 8.0; execute in a new, empty practice database.
CREATE TABLE `student` (
    `sno`   CHAR(8) PRIMARY KEY COMMENT '学号',
    `sname` VARCHAR(20) NOT NULL COMMENT '姓名',
    `ssex`  CHAR(2) COMMENT '性别',
    `sage`  SMALLINT COMMENT '年龄',
    `sdept` VARCHAR(20) COMMENT '院系'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生表';

CREATE TABLE `course` (
    `cno`     CHAR(6) PRIMARY KEY COMMENT '课程号',
    `cname`   VARCHAR(40) NOT NULL COMMENT '课程名',
    `credit`  INT COMMENT '学分',
    `teacher` VARCHAR(20) COMMENT '任课教师'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程表';

CREATE TABLE `sc` (
    `sno`   CHAR(8) COMMENT '学号',
    `cno`   CHAR(6) COMMENT '课程号',
    `grade` DECIMAL(5,1) COMMENT '成绩',
    PRIMARY KEY (`sno`, `cno`),
    CONSTRAINT `fk_sc_student`
        FOREIGN KEY (`sno`) REFERENCES `student`(`sno`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_sc_course`
        FOREIGN KEY (`cno`) REFERENCES `course`(`cno`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='选课表';

CREATE TABLE `student` (
    `sno`   CHAR(8) PRIMARY KEY COMMENT '学号',
    `sname` VARCHAR(20) NOT NULL COMMENT '姓名',
    `ssex`  CHAR(2) COMMENT '性别',
    `sage`  SMALLINT COMMENT '年龄',
    `sdept` VARCHAR(20) COMMENT '院系',
    CONSTRAINT `chk_student_sex` CHECK (`ssex` IN ('男', '女')),
    CONSTRAINT `chk_student_age` CHECK (`sage` BETWEEN 16 AND 30)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生表';

CREATE TABLE `course` (
    `cno`     CHAR(6) PRIMARY KEY COMMENT '课程号',
    `cname`   VARCHAR(40) NOT NULL COMMENT '课程名',
    `credit`  DECIMAL(3,1) NOT NULL COMMENT '学分',
    `teacher` VARCHAR(20) COMMENT '任课教师'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程表';

CREATE TABLE `sc` (
    `sno`   CHAR(8) COMMENT '学号',
    `cno`   CHAR(6) COMMENT '课程号',
    `grade` DECIMAL(5,1) COMMENT '成绩',
    PRIMARY KEY (`sno`, `cno`),
    CONSTRAINT `fk_sc_student`
        FOREIGN KEY (`sno`) REFERENCES `student`(`sno`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_sc_course`
        FOREIGN KEY (`cno`) REFERENCES `course`(`cno`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='选课表';