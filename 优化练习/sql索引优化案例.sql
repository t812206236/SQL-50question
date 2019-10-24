#尚硅谷第44节课，因为该节课罗列了不同sql语句导致的不同的情况，所以单独将这节课的内容拿出来做个笔记
#也方便以后在此做实验和回顾

create database mysql_advanced;
use mysql_advanced;
create table test03(
id int primary key not null auto_increment,
c1 char(10),
c2 char(10),
c3 char(10),
c4 char(10),
c5 char(10));

insert into test03(c1,c2,c3,c4,c5) values('a1','a2','a3','a4','a5');
insert into test03(c1,c2,c3,c4,c5) values('b1','b2','b3','b4','b5');
insert into test03(c1,c2,c3,c4,c5) values('c1','c2','c3','c4','c5');
insert into test03(c1,c2,c3,c4,c5) values('d1','d2','d3','d4','d5');
insert into test03(c1,c2,c3,c4,c5) values('e1','e2','e3','e4','e5');

select * from test03;

create index idx_test03_c1234 on test03(c1,c2,c3,c4);

#开头中间索引都有，ref是const级别的，条件值越多，key_len越长
explain select * from test03 where c1='a1' and c2='a2' and c3='a3' and c4='a4';
#即使顺序被打乱也没有关系，mysql有optimizer，保证索引能够按序被使用
explain select * from test03 where c1='a1' and c2='a2' and c4='a4' and c3='a3';
#c1 c2都用到，但是c3是范围，只用到了排序没用到查找，范围后失效，所以c4的索引失效
explain select * from test03 where c1='a1' and c2='a2' and c3>'a3' and c4='a4';
#此处用到了四个索引，只不过第四个type是范围
explain select * from test03 where c1='a1' and c2='a2' and c4>'a4' and c3='a3';
#用到了c1，c2,c3用于排序，所以c4断了
explain select * from test03 where c1='a1' and c2='a2' and c4='a4' order by c3 ;
#用来验证上面这条看c4是否会影响
explain select * from test03 where c1='a1' and c2='a2' order by c3 ;
#c3条件断掉，不仅会影响查找，还会影响排序，这种情况下c4的排序会让sql执行产生文件内排序，需要优化
explain select * from test03 where c1='a1' and c2='a2' order by c4 ;
#索引中间没有断,c1,c2,c3全用到，只不过c2,c3用于了排序
explain select * from test03 where c1='a1' and c5='a5' order by c2,c3 ;
#排序这里没有被优化导致索引失效了，emm......好吧
explain select * from test03 where c1='a1' and c5='a5' order by c3,c2 ;

explain select * from test03 where c1='a1' and c2='a2' order by c2,c3 ;

explain select * from test03 where c1='a1' and c2='a2' and c5='a5' order by c2,c3 ;
#c2已经是常量了，不会再排序，所以order by条件颠倒也没有影响
explain select * from test03 where c1='a1' and c2='a2' and c5='a5' order by c3,c2 ;
#group by不举例了和order by相似

#特殊例子，虽然c2是个范围但是c3却没有失效
explain select * from test03 where c1='a1' and c2 like 'a2%' and c3='a3';
#但不意味着%放前面就是对的，type不是ref不是range
explain select * from test03 where c1='a1' and c2 like '%a2' and c3='a3';