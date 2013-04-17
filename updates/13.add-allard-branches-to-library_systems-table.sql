-- giving Bibliotheque Allard the ability to forward requests to its branches

insert into library_systems (parent_id, child_id) values ( (select lid from libraries where name='MSTG'), (select lid from libraries where name='MVBB'));
insert into library_systems (parent_id, child_id) values ( (select lid from libraries where name='MSTG'), (select lid from libraries where name='MBBB'));

update libraries set can_forward_to_children = true where name='MSTG';
update libraries set city='Traverse Bay' where name='MVBB';
update libraries set city='Grand Marais' where name='MBBB';