create database studysql;
use studysql;

-- 查询姓猴的学生名单
select * from student where 姓名 like '猴%';
-- 查询最后一个字是猴的学生名单
select * from student where 姓名 like '%猴';
-- 查询名字中带猴的学生名单
select * from student where 姓名 like '%猴%';
-- 查询姓孟的老师的个数
select count(*) from teacher where 教师姓名 like '孟%';

-- 查询课程编号为0002的总成绩
select sum(成绩) from score where 课程号=0002;
-- 查询选了课程的学生人数
select count(distinct 学号) from score;

-- 先看下面的文章了解一下group by
-- https://blog.csdn.net/intmainhhh/article/details/80777582
-- 查询各科成绩最高和最低的分
select 课程号,min(成绩),max(成绩) from score group by 课程号;
-- 查询每门课程被选修的学生数
select 课程号,count(学号) as 人数 from score group by 课程号;
-- 查询男生、女生人数
select 性别,count(*) as 数量 from student group by 性别;

-- 查询平均成绩大于60分学生的学号和平均成绩
-- having能够对分组后的结果进行筛选
select 学号,avg(成绩) from score group by 学号 having avg(成绩)>60;
-- 查询至少选修两门课程的学生学号
select 学号,count(*) as 选修数量 from score group by 学号 having count(*)>=2;
-- 查询同姓名学生名单并统计同名人数
select 姓名,count(*) as 重复数量 from student group by 姓名 having count(*)>=2;
-- 查询同姓名同性别学生名单并统计同名人数
select 姓名,count(*) as 同姓名同性别 from student 
group by 姓名,性别 having count(*)>=2;
-- 查询不及格的课程并按课程号从大到小排列
select * from score where 成绩<60 order by 课程号 desc;
-- 查询每门课程的平均成绩，结果按平均成绩升序排序，平均成绩相同时，按课程号降序排列
select 课程号,avg(成绩) from score group by 课程号 order by avg(成绩) asc,课程号 desc;
-- 检索课程编号为“0004”且分数小于60的学生学号，结果按按分数降序排列
select * from score where 课程号='0004' and 成绩<60 order by 成绩 desc;
-- 要求输出课程号和选修人数，查询结果按人数降序排序，若人数相同，按课程号升序排序
select 课程号,count(*) from score group by 课程号 order by count(*) desc,课程号 asc;
-- 查询两门以上不及格课程的同学的学号及其平均成绩
select 学号,avg(成绩) from score where 成绩 <60 group by 学号 having count(*)>=2;

-- 查询所有课程成绩小于60分学生的学号、姓名
select 学号,姓名 from student where  学号 in ( select 学号  from score where 成绩 < 60 );
-- 查询没有学全所有课的学生的学号、姓名
select 学号,姓名 from student where 学号 in 
(select 学号 from score group by 学号 having count(*)<> (select count(*) from course));
-- 上面这个应该是错了，毕竟王思聪连课程都没选，所以应该用not in比较合适
select 学号,姓名 from student where 学号 not in 
(select 学号 from score group by 学号 having count(*)= (select count(*) from course));
-- 查询出只选修了两门课程的全部学生的学号和姓名
select 学号,姓名 from student where 学号 in 
(select 学号 from score group by 学号 having count(*)= 2);

-- 1990年出生的学生名单
select 学号,姓名 
from student 
where year(出生日期)=1990;

-- 查询各科成绩前两名的记录，这个是猴子自己的方法
(select * from score where 课程号 = '0001' order by 成绩  desc limit 2)
union all
(select * from score where 课程号 = '0002' order by 成绩  desc limit 2)
union all
(select * from score where 课程号 = '0003' order by 成绩  desc limit 2);
-- 也可以这样写
-- 自己和自己左连查询，将主表分组，副表就会有会有多个值对应，对多个值计算数量即可得知
-- 比当前成绩大的成绩有多少个
select s.课程号,s.学号,s.成绩 from score s 
left join score ss on s.课程号=ss.课程号 and s.成绩<ss.成绩
group by s.学号,s.课程号,s.成绩
having count(*)<2
order by s.课程号,s.成绩 desc;
-- 还可以这样写
-- 如果在当前课程中 比 当前成绩大 的 数量小于2 ，说明当前成绩是前2的成绩，允许同时前2的情况发生
select * from score s where 2 >
(select count(*) from score where 课程号=s.课程号 and 成绩>s.成绩)
order by s.课程号,s.成绩 desc;

-- 查询所有学生的学号、姓名、选课数、总成绩
select a.学号,a.姓名,count(b.课程号) as 选课数,sum(b.成绩) as 总成绩
from student as a left join score as b
on a.学号 = b.学号
group by a.学号;
-- 查询平均成绩大于85的所有学生的学号、姓名和平均成绩
select a.学号,a.姓名, avg(b.成绩) as 平均成绩
from student as a left join score as b
on a.学号 = b.学号
group by a.学号
having avg(b.成绩)>85;
-- 查询学生的选课情况：学号，姓名，课程号，课程名称
select a.学号, a.姓名, c.课程号,c.课程名称
from student a inner join score b on a.学号=b.学号
inner join course c on b.课程号=c.课程号;
-- 查询出每门课程的及格人数和不及格人数
-- 考察case表达式
select 课程号,
sum(case when 成绩>=60 then 1 
	 else 0 
    end) as 及格人数,
sum(case when 成绩 <  60 then 1 
	 else 0 
    end) as 不及格人数
from score
group by 课程号;
-- 使用分段[100-85],[85-70],[70-60],[<60]来统计各科成绩，分别统计：各分数段人数，课程号和课程名称
-- 考察case表达式
select a.课程号,b.课程名称,
sum(case when 成绩 between 85 and 100 
	 then 1 else 0 end) as '[100-85]',
sum(case when 成绩 >=70 and 成绩<85 
	 then 1 else 0 end) as '[85-70]',
sum(case when 成绩>=60 and 成绩<70  
	 then 1 else 0 end) as '[70-60]',
sum(case when 成绩<60 then 1 else 0 end) as '[<60]'
from score as a right join course as b 
on a.课程号=b.课程号
group by a.课程号,b.课程名称;
-- 查询课程编号为0003且课程成绩在80分以上的学生的学号和姓名
select a.学号,a.姓名
from student  as a inner join score as b on a.学号=b.学号
where b.课程号='0003' and b.成绩>80;