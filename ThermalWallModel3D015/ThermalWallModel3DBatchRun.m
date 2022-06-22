%%

c = parcluster;
%%

ppn = 32; 
totalProcs = 31;
c.setQueueName('matlab');
c.setProcsPerNode(ppn);

pathName = pwd;
fileName = [pathName,'/ThermalWallModel3D'];

% when you want to run a job using 2K digraphs and 30K parameters
neighbor1 = c.batch(@modelAll_v3_neighbor,1,{randDigraphs2000, newParameters2},'Pool',totalProcs,'AttachedFiles',{fileName});
