Points = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 0 1; 1 1 0; 0 1 1; 1 1 1]

gm = alphaShape(Points)

[elements,nodes] = boundaryFacets(gm);





model = createpde

nodes = nodes';
elements = elements';
geometryFromMesh(model,nodes,elements);

pdegplot(model,'CellLabels','on','FaceAlpha',0.5)