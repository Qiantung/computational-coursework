-- Entirely synthetic records. Run schema.sql in an empty MySQL 8 database first.
INSERT INTO student VALUES ('D0000001','Demo Student A','',20,'Demo Department'),('D0000002','Demo Student B','',21,'Demo Department');
INSERT INTO course VALUES ('DEMO01','Database Lab',3,'Demo Teacher');
INSERT INTO sc VALUES ('D0000001','DEMO01',80),('D0000002','DEMO01',90);
SELECT course.cname, COUNT(*) AS enrollments, AVG(sc.grade) AS mean_grade
FROM sc JOIN course ON sc.cno=course.cno GROUP BY course.cno,course.cname;
