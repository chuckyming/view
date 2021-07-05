-- 1、查询"01"课程比"02"课程成绩高的学生的信息及课程分数

select student.*,a.s_score as 01_score,b.s_score as 02_score
from student
join score a on student.s_id=a.s_id and a.c_id='01'
left join score b on student.s_id=b.s_id and b.c_id='02' or b.c_id=null
where  a.s_score>b.s_score;

--答案2
select student.*,a.s_score as 01_score,b.s_score as 02_score
from student
join score a on  a.c_id='01'
join score b on  b.c_id='02'
where  a.s_id=student.s_id and b.s_id=student.s_id and a.s_score>b.s_score;

-- 2、查询"01"课程比"02"课程成绩低的学生的信息及课程分数

select student.*,a.s_score as 01_score,b.s_score as 02_score
from student
join score a on student.s_id=a.s_id and a.c_id='01' or a.c_id=null
left join score b on student.s_id=b.s_id and b.c_id='02'
where a.s_score<b.s_score;

--答案2
select student.*,a.s_score as 01_score,b.s_score as 02_score
from student
join score a on  a.c_id='01'
join score b on  b.c_id='02'
where  a.s_id=student.s_id and b.s_id=student.s_id and a.s_score<b.s_score;


-- 3、查询平均成绩大于等于60分的同学的学生编号和学生姓名和平均成绩

select  student.s_id,student.s_name,tmp.avg_score from student
join (
select score.s_id,round(avg(score.s_score),1)as avg_score from score group by s_id)as tmp
on tmp.avg_score>=60
where student.s_id=tmp.s_id;

--答案2
select  student.s_id,student.s_name,round(avg (score.s_score),1) as avg_score from student
join score on student.s_id=score.s_id
group by score.s_id
having avg (score.s_score)>=60;


-- 4、查询平均成绩小于60分的同学的学生编号和学生姓名和平均成绩
        -- (包括有成绩的和无成绩的)

select  student.s_id,student.s_name,tmp.avg_score from student
join (
select score.s_id,round(avg(score.s_score),1)as avg_score from score group by s_id)as tmp
on tmp.avg_score < 60
where student.s_id=tmp.s_id
union
select  s_id,s_name,0 as avg_score from student
where s_id not in
    (select distinct s_id from score);

--答案2
select  student.s_id,student.s_name,round(avg (score.s_score),1) as avg_score from student
join score on student.s_id=score.s_id
group by score.s_id
having avg (score.s_score) < 60
union
select  s_id,s_name,0 as avg_score from student
where s_id not in
    (select distinct s_id from score);


-- 5、查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩

select student.s_id,student.s_name,(count(score.c_id) )as total_count,sum(score.s_score)as total_score
from student
left join score on student.s_id=score.s_id
group by score.s_id;


-- 6、查询"李"姓老师的数量

select t_name,count(1) from teacher where t_name like '李%';


-- 7、查询学过"张三"老师授课的同学的信息

select * from student
    join score on student.s_id =score.s_id where score.c_id in (
        select course.c_id from course
            where course.t_id in (
        select teacher.t_id from teacher
            where teacher.t_name='张三'
        )
);

--答案2
select student.* from student
join score on student.s_id =score.s_id
join  course on course.c_id=score.c_id
join  teacher on course.t_id=teacher.t_id and t_name='张三';

-- 8、查询没学过"张三"老师授课的同学的信息

select * from student
   where s_id not in (
      select score.s_id from score where score.c_id  in (
      select course.c_id from course where course.t_id   = (
      select teacher.t_id from teacher where teacher.t_name='张三' ))
);

--答案2
select student.* from student
left join (select s_id from score
      join  course on course.c_id=score.c_id
      join  teacher on course.t_id=teacher.t_id and t_name='张三')tmp
on  student.s_id =tmp.s_id
where tmp.s_id is null;


-- 9、查询学过编号为"01"并且也学过编号为"02"的课程的同学的信息

select * from student
   where s_id in (
      select s_id from score where c_id =1 )
   and s_id in (
      select s_id from score where c_id =2
);


-- 10、查询学过编号为"01"但是没有学过编号为"02"的课程的同学的信息

select * from student
   where s_id in (
      select s_id from score where c_id =1 )
   and s_id not in (
      select s_id from score where c_id =2
);

--答案2
select student.* from student
join (select s_id from score where c_id =1 )tmp1
    on student.s_id=tmp1.s_id
left join (select s_id from score where c_id =2 )tmp2
    on student.s_id =tmp2.s_id
where tmp2.s_id is null;


-- 11、查询没有学全所有课程的同学的信息

select * from student
   where s_id in (
      select s_id
        from score
          group by s_id
            having count(c_id)=(
               select count(1) from course)
);


-- 12、查询至少有一门课与学号为"01"的同学所学相同的同学的信息

select * from student
  where s_id<>01 and s_id in (
    select s_id from score  where c_id in (
      select c_id from score
        where score.s_id=01)
    group by s_id
);


-- 13、查询和"01"号的同学学习的课程完全相同的其他同学的信息

select student.*,tmp.course_id from
  (select s_id ,group_concat(c_id) course_id
      from score group by s_id  having s_id<>1 and course_id =(
        select group_concat(c_id) course_id2
            from score  where s_id=1))tmp
  join student on student.s_id=tmp.s_id;


-- 14、查询没学过"张三"老师讲授的任一门课程的学生姓名

select * from student where s_id not in (
  select s_id from score
  join (
      select c_id from course where t_id in (
        select t_id from teacher where t_name='张三')
  )tmp
  on score.c_id=tmp.c_id);

--答案2
select student.* from student
  left join (select s_id from score
          join (select c_id from course join  teacher on course.t_id=teacher.t_id and t_name='张三')tmp2
          on score.c_id=tmp2.c_id )tmp
  on student.s_id = tmp.s_id
  where tmp.s_id is null;
  
  
-- 15、查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩

select student.s_id,student.s_name,tmp.avg_score from student
left join (
    select s_id,round(AVG (score.s_score)) avg_score
      from score group by s_id)tmp
      on tmp.s_id=student.s_id
where student.s_id in (
    select s_id from score
      where s_score<60
        group by score.s_id having count(s_id)>1
);


-- 16、检索"01"课程分数小于60，按分数降序排列的学生信息

select student.*,s_score from student,score
where student.s_id=score.s_id and s_score<60 and c_id='01'
order by s_score desc;


-- 17、按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩

select s_id,
    (select s_score  from score where s_id=a.s_id and c_id='01')as '语文',
    (select s_score  from score where s_id=a.s_id and c_id='02')as '数学',
    (select s_score  from score where s_id=a.s_id and c_id='03')as '英语',
    round(avg (s_score),2) as '平均分'
from score a group by s_id order by '平均分' desc;

--答案2
select a.s_id,tmp1.s_score as chinese,tmp2.s_score as math,tmp3.s_score as english,
    round(avg (a.s_score),2) as avgScore
from score a
left join (select s_id,s_score  from score s1 where  c_id='01')tmp1 on  tmp1.s_id=a.s_id
left join (select s_id,s_score  from score s2 where  c_id='02')tmp2 on  tmp2.s_id=a.s_id
left join (select s_id,s_score  from score s3 where  c_id='03')tmp3 on  tmp3.s_id=a.s_id
group by a.s_id,tmp1.s_score,tmp2.s_score,tmp3.s_score order by avgScore desc;


-- 18.查询各科成绩最高分、最低分和平均分：以如下形式显示：课程ID，课程name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
--及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90

select score.c_id as '课程ID',course.c_name as '课程name',max(s_score) as '最高分',min(s_score)as '最低分',
    round(avg(s_score),2) '平均分',
    round(sum(case when s_score>=60 then 1 else 0 end)/sum(case when s_score then 1 else 0 end),2)'及格率',
    round(sum(case when s_score>=70 and s_score<80 then 1 else 0 end)/sum(case when s_score then 1 else 0 end),2)'中等率',
    round(sum(case when s_score>=80 and s_score<90 then 1 else 0 end)/sum(case when s_score then 1 else 0 end),2)'优良率',
    round(sum(case when s_score>=90 then 1 else 0 end)/(SUM(case when s_score then 1 else 0 end)),2)'优秀率'
from score left join course on score.c_id=course.c_id
group by score.c_id;


-- 19、按各科成绩进行排序，并显示排名(实现不完全)
-- mysql没有rank函数
--方法1
(select * from
  (select s1.s_id,s1.c_id,s1.s_score,
      (select count(distinct sc.s_score) from score sc
          where sc.s_score>=s1.s_score and sc.c_id='01') 'rank不保留排名'
from score s1 where s1.c_id='01'order by s1.s_score desc) t1 )
union (select * from
  (select s1.s_id,s1.c_id,s1.s_score,
      (select count(distinct sc.s_score) from score sc
          where sc.s_score>=s1.s_score and sc.c_id='02') 'rank不保留排名'
from score s1 where s1.c_id='02' order by s1.s_score desc) t2 )
union (select * from
  (select s1.s_id,s1.c_id,s1.s_score,
      (select count(distinct sc.s_score) from score sc
          where sc.s_score>=s1.s_score and sc.c_id='03') 'rank不保留排名'
from score s1 where s1.c_id='03' order by s1.s_score desc) t3 )

--方法2
(select a.s_id,a.c_id,@i:=@i+1 as i保留排名,
      @k:=(case when @score=a.s_score then @k else @i end) as rank不保留排名,
      @score:=a.s_score as score
from(select * from score where c_id='01' GROUP BY s_id,c_id,s_score order by s_score desc )a,
(select @i:=0,@k:=0,@score:=0)b)
union
(select a.s_id,a.c_id,@m:=@m+1 as i保留排名,
      @k:=(case when @score=a.s_score then @k else @m end) as rank不保留排名,
      @score:=a.s_score as score
from(select * from score where c_id='02' GROUP BY s_id,c_id,s_score order by s_score desc )a,
(select @m:=0,@k:=0,@score:=0)b)
union
(select a.s_id,a.c_id,@x:=@x+1 as i保留排名,
      @k:=(case when @score=a.s_score then @k else @x end) as rank不保留排名,
      @score:=a.s_score as score
from(select * from score where c_id='03' GROUP BY s_id,c_id,s_score order by s_score desc )a,
(select @x:=0,@k:=0,@score:=0)b);


-- 20、查询学生的总成绩并进行排名

select score.s_id,s_name,sum(s_score) sumscore
  from score ,student
    where score.s_id=student.s_id
    group by score.s_id order by sumscore desc;


-- 21、查询不同老师所教不同课程平均分从高到低显示
--方法1
select tmp.c_id,t_id,avgscore as '平均分' from(
    (select distinct c_id ,(round((select avg(s_score) from score
        where c_id='01' group by c_id),2))avgscore from score s1 where c_id='01')
union
    (select distinct c_id ,(round((select avg(s_score) from score
        where c_id='02' group by c_id),2))avgscore from score s1 where c_id='02')
union
    (select distinct c_id ,(round((select avg(s_score) from score
        where c_id='03' group by c_id),2))avgscore from score s1 where c_id='03')
)tmp ,course where tmp.c_id=course.c_id order by tmp.avgscore desc;

--方法2
select course.c_id,course.t_id,t_name,round(avg(s_score),2)as avgscore from course
    join teacher on teacher.t_id=course.t_id
    join score on course.c_id=score.c_id
    group by score.c_id order by avgscore desc;

--方法3
select course.c_id,course.t_id,t_name,round(avg(s_score),2)as avgscore from course,teacher,score
   where teacher.t_id=course.t_id and course.c_id=score.c_id
    group by score.c_id order by avgscore desc;


-- 22、查询所有课程的成绩第2名到第3名的学生信息及该课程成绩
--方法1
(select student.*,tmp1.c_id,tmp1.s_score from student,
    (select s_id,c_id,s_score from score where c_id='01' order by s_score desc limit 1,2)tmp1
        where student.s_id=tmp1.s_id)
union(select student.*,tmp2.c_id,tmp2.s_score from student,
    (select s_id,c_id,s_score from score where c_id='02' order by s_score desc limit 1,2)tmp2
        where student.s_id=tmp2.s_id)
union(select student.*,tmp3.c_id,tmp3.s_score from student,
    (select s_id,c_id,s_score from score where c_id='03' order by s_score desc limit 1,2)tmp3
        where student.s_id=tmp3.s_id)

--方法2
(select student.*,tmp.c_id,tmp.s_score,tmp.排名 from(
    select a.s_id,a.c_id,a.s_score,@i:=@i+1 as 排名 from score a,(select @i:=0)b
      where a.c_id='01' order by a.s_score desc
)tmp join student on tmp.s_id=student.s_id where 排名 between 2 and 3)
union (
select student.*,tmp.c_id,tmp.s_score,tmp.排名 from(
    select a.s_id,a.c_id,a.s_score,@j:=@j+1 as 排名 from score a,(select @j:=0)b
      where a.c_id='02' order by a.s_score desc
)tmp join student on tmp.s_id=student.s_id where 排名 between 2 and 3
)union (
select student.*,tmp.c_id,tmp.s_score,tmp.排名 from(
    select a.s_id,a.c_id,a.s_score,@k:=@k+1 as 排名 from score a,(select @k:=0)b
      where a.c_id='03' order by a.s_score desc
)tmp join student on tmp.s_id=student.s_id where 排名 between 2 and 3)


-- 23、统计各科成绩各分数段人数：课程编号,课程名称,[100-85],[85-70],[70-60],[0-60]及所占百分比

select c.c_id,c.c_name,tmp1.`[0-60]`, tmp1.`百分比`,tmp2.`[60-70]`, tmp2.`百分比`,tmp3.`[70-85]`, tmp3.`百分比`,tmp4.`[85-100]`, tmp4.`百分比` from course c
join
(select c_id,sum(case when s_score<60 then 1 else 0 end )as '[0-60]',
    round(100*sum(case when s_score<60 then 1 else 0 end )/sum(case when s_score then 1 else 0 end ),2)as 百分比
from score group by c_id)tmp1 on tmp1.c_id =c.c_id
join
(select c_id,sum(case when s_score<70 and s_score>=60 then 1 else 0 end )as '[60-70]',
    round(100*sum(case when s_score<70 and s_score>=60 then 1 else 0 end )/sum(case when s_score then 1 else 0 end ),2)as 百分比
from score group by c_id)tmp2 on tmp2.c_id =c.c_id
join
(select c_id,sum(case when s_score<85 and s_score>=70 then 1 else 0 end )as '[70-85]',
    round(100*sum(case when s_score<85 and s_score>=70 then 1 else 0 end )/sum(case when s_score then 1 else 0 end ),2)as 百分比
from score group by c_id)tmp3 on tmp3.c_id =c.c_id
join
(select c_id,sum(case when s_score>=85 then 1 else 0 end )as '[85-100]',
    round(100*sum(case when s_score>=85 then 1 else 0 end )/sum(case when s_score then 1 else 0 end ),2)as 百分比
from score group by c_id)tmp4 on tmp4.c_id =c.c_id


-- 24、查询学生平均成绩及其名次

select a.s_id,a.s_name,a.平均分,@i:=@i+1 as 排名 from
    (select student.s_id,student.s_name,avg(score.s_score) as "平均分"  from student,score
        where student.s_id=score.s_id
        group by score.s_id order by `平均分` desc)a,
    (select @i:=0)b


-- 25、查询各科成绩前三名的记录
            -- 1.选出b表比a表成绩大的所有组
            -- 2.选出比当前id成绩大的 小于三个的
--没有查学生姓名
(select score.c_id,course.c_name,s_score from score,course
    where score.c_id='01'and course.c_id=score.c_id order by s_score desc limit 3)
union
(select score.c_id,course.c_name,s_score from score,course
    where score.c_id='02'and course.c_id=score.c_id order by s_score desc limit 3)
union
(select score.c_id,course.c_name,s_score from score,course
    where score.c_id='03'and course.c_id=score.c_id order by s_score desc limit 3)

--查了学生姓名
(select score.c_id,course.c_name,student.s_name,s_score from score
    join student on student.s_id=score.s_id
    join course on  score.c_id='01' and course.c_id=score.c_id  order by s_score desc limit 3)
union (
select score.c_id,course.c_name,student.s_name,s_score from score
    join student on student.s_id=score.s_id
    join course on  score.c_id='02' and course.c_id=score.c_id  order by s_score desc limit 3

)union (
select score.c_id,course.c_name,student.s_name,s_score from score
    join student on student.s_id=score.s_id
    join course on  score.c_id='03' and course.c_id=score.c_id  order by s_score desc limit 3)


-- 26、查询每门课程被选修的学生数

select c.c_id,c.c_name,a.`被选修人数` from course c
    join (select c_id,count(1) as `被选修人数` from score
        where score.s_score<60 group by score.c_id)a
    on a.c_id=c.c_id


-- 27、查询出只有两门课程的全部学生的学号和姓名

select st.s_id,st.s_name from student st
  join (select s_id from score group by s_id having count(c_id) =2)a
    on st.s_id=a.s_id


-- 28、查询男生、女生人数

select a.男生人数,b.女生人数 from
    (select count(1) as 男生人数 from student where s_sex='男')a,
    (select count(1) as 女生人数 from student where s_sex='女')b


-- 29、查询名字中含有"风"字的学生信息

select * from student where s_name like '%风%'

-- 30、查询同名同性学生名单，并统计同名人数

select s1.s_id,s1.s_name,s1.s_sex,count(*) as 同名人数  from student s1,student s2
    where s1.s_name=s2.s_name and s1.s_id<>s2.s_id and s1.s_sex=s2.s_sex
    group by s1.s_name,s1.s_sex

-- 31、查询1990年出生的学生名单

select * from student where s_birth like '1990%'

-- 32、查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列

select score.c_id,c_name,round(avg(s_score),2) as 平均成绩 from score
  join course on score.c_id=course.c_id
    group by c_id order by `平均成绩` desc,score.c_id asc


-- 33、查询平均成绩大于等于85的所有学生的学号、姓名和平均成绩

select score.s_id,s_name,round(avg(s_score),2)as 平均成绩 from score
    join student on student.s_id=score.s_id
    group by score.s_id having `平均成绩` >= 85


-- 34、查询课程名称为"数学"，且分数低于60的学生姓名和分数

select s_name,s_score as 数学成绩 from student
    join (select s_id,s_score from score,course where score.c_id=course.c_id and c_name='数学')a
    on a.s_score < 60 and student.s_id=a.s_id


-- 35、查询所有学生的课程及分数情况

select a.s_name,
    SUM(case c.c_name when '语文' then b.s_score else 0 end ) as 语文,
    SUM(case c.c_name when '数学' then b.s_score else 0 end ) as 数学,
    SUM(case c.c_name when '英语' then b.s_score else 0 end ) as 英语,
    SUM(b.s_score) as 总分
  from student a
    join score b on a.s_id=b.s_id
    join course c on b.c_id=c.c_id
    group by s_name,a.s_id


-- 36、查询任何一门课程成绩在70分以上的学生姓名、课程名称和分数

select s_name,c_name,s_score from score
    join student on student.s_id=score.s_id
    join course on score.c_id=course.c_id
  where s_score < 70


-- 37、查询不及格的课程

select s_name,c_name as 不及格课程,tmp.s_score from student
    join (select s_id,s_score,c_name from score,course where score.c_id=course.c_id and s_score < 60)tmp
    on student.s_id=tmp.s_id


--38、查询课程编号为01且课程成绩在80分以上的学生的学号和姓名

select student.s_id,s_name,s_score as score_01 from student
    join score on student.s_id=score.s_id
    where c_id='01' and s_score >= 80


-- 39、求每门课程的学生人数

select course.c_id,course.c_name,count(1)as 选课人数 from course
    join score on course.c_id=score.c_id
    group by score.c_id


-- 40、查询选修"张三"老师所授课程的学生中，成绩最高的学生信息及其成绩
      -- 查询老师id
select t_id,t_name from teacher where t_name='张三'
      -- 查询最高分（可能有相同分数）
select s_id,c_name,max(s_score) from score
  join (select course.c_id,c_name from course,
            (select t_id,t_name from teacher where t_name='张三')tmp
        where course.t_id=tmp.t_id)tmp2
  on score.c_id=tmp2.c_id
      -- 查询信息
select student.*,tmp3.c_name as 课程名称,tmp3.最高分 from student
    join (select s_id,c_name,max(s_score)as 最高分 from score
            join (select course.c_id,c_name from course,
                  (select t_id,t_name from teacher where t_name='张三')tmp
               where course.t_id=tmp.t_id)tmp2
            on score.c_id=tmp2.c_id)tmp3
    on student.s_id=tmp3.s_id

-- 41、查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩

select distinct a.s_id,a.c_id,a.s_score from score a,score b
    where a.c_id <> b.c_id and a.s_score=b.s_score

-- 42、查询每门课程成绩最好的前三名
--方法1(牛逼的写法)
select a.s_id,a.c_id,a.s_score from score a
    where (select count(1) from score b where a.c_id=b.c_id and b.s_score >= a.s_score) < 2
    order by a.c_id asc ,a.s_score desc


--方法2
(select * from score where c_id ='01' order by s_score desc limit 3)
union (
select * from score where c_id ='02' order by s_score desc limit 3)
union (
select * from score where c_id ='03' order by s_score desc limit 3)


-- 43、统计每门课程的学生选修人数（超过5人的课程才统计）。要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列

select distinct course.c_id,tmp.选修人数 from course
    join (select c_id,count(1) as 选修人数 from score group by c_id)tmp
    where tmp.选修人数>=5 order by tmp.选修人数 desc ,course.c_id asc

-- 44、检索至少选修两门课程的学生学号

select s_id,count(c_id) as totalCourse from score group by s_id having count(c_id) >= 2

-- 45、查询选修了全部课程的学生信息

select student.* from student,(select s_id,count(c_id) as totalCourse from score group by s_id)tmp
    where student.s_id=tmp.s_id and totalCourse=3

--46、查询各学生的年龄
    -- 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
select s_name,s_birth,(DATE_FORMAT(NOW(),'%Y')-DATE_FORMAT(s_birth,'%Y')-
    case when (DATE_FORMAT(NOW(),'%m%d') > DATE_FORMAT(s_birth,'%m%d')) then 1 else 0 end ) as age
    from student

-- 47、查询本周过生日的学生
--方法1
select * from student where WEEK(DATE_FORMAT(NOW(),'%Y%m%d'))+1 =WEEK(s_birth)

--方法2
select s_name,s_sex,s_birth from student
    where substring(s_birth,6,2)='10'
    and substring(s_birth,9,2)=14

-- 48、查询下周过生日的学生
--方法1
select * from student where WEEK(DATE_FORMAT(NOW(),'%Y%m%d'))+1 =WEEK(s_birth)

--方法2
select s_name,s_sex,s_birth from student
    where substring(s_birth,6,2)='10'
    and substring(s_birth,9,2)>=15
    and substring(s_birth,9,2)<=21

-- 49、查询本月过生日的学生
--方法1
select * from student where MONTH(DATE_FORMAT(NOW(),'%Y%m%d'))+1 =MONTH(s_birth)
--方法2
select s_name,s_sex,s_birth from student where substring(s_birth,6,2)='10'

-- 50、查询12月份过生日的学生
select s_name,s_sex,s_birth from student where substring(s_birth,6,2)='12'

