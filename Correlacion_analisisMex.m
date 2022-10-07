
%---------México---------
%---------Identificación de Nulos---------

%Identificamos la matriz de datos faltantes del DataFrame
Matriz_Null= ismissing(Mexico);

%Identificamos la cantidad de datos faltantes por Columna
%Columna 13 "last_review" y 14 "reviews_per_month" cuentan con 3990 valores
%nulos cada una
%Columna 18 "license"se encuentra vacia
Column_Null= sum(Matriz_Null)

%Eliminamos la columna "license" y "neighbourhood_group"
Mexico(:,18) = [];
Mexico(:,5) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------Sustitución de Nulos---------

%Rellenamos datos faltantes por DataFrame usando diferentes métodos
data2 = fillmissing(Mexico,'next','DataVariables',{'last_review'});
data3 = fillmissing(data2,'movmean', 50,'DataVariable',{'reviews_per_month'})

%Corroboramos que no haya nulos
Matriz_Null2= ismissing(data3);
Column_Null2= sum(Matriz_Null2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Identificación de Outliers---------

%Identificamos Matriz de outliers mediante método de desviación estándar
Outliers = isoutlier(data3,'mean','DataVariables',{'latitude','longitude','price','minimum_nights','number_of_reviews','reviews_per_month','calculated_host_listings_count','availability_365','number_of_reviews_ltm'});
%Identificamos la cantidad de outliers por Columna
Column_outliers= sum(Outliers);
%Identificamos la cantidad de datos faltantes por DataFrame
Data_Outliers= sum(Column_outliers)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Sustitución de Outliers---------

% Las variables 'latitude' y 'longitude' tienen outliers, sin embargo al
% ser coordenadas si se sustituyen tendremos un error con los datos. Por lo
% tanto los dejaremos igual

% La variable 'reviews_per_month' se sustituirá por el método linear
data3_outliers = filloutliers(data3,'linear','DataVariables',{'reviews_per_month'});

% Las variables 'price','minimum_nights','number_of_reviews','calculated_host_listings_count', 'number_of_reviews_ltm',
% se sustituiran por center
data3_clean = filloutliers(data3_outliers,'center','DataVariables',{'price','minimum_nights','number_of_reviews','calculated_host_listings_count', 'number_of_reviews_ltm'})

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Filtros de Datos---------

%Selecionamos solo las columnas numericas que necesitamos para hacer el
%análisis de correlaciones:

%price=1
%minimum_nights=2
%number_of_reviews=3
%reviews_per_month=4
%calculated_host_listings_count=5
% availability_365=6
% number_of_reviews_ltm=7

Filtro_Corre= data3_clean(:,[9,10,11,13,14,15,16]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Correlación de datos---------

%Matriz de correlaciones del Dataframe
Matriz=table2array(Filtro_Corre); %esta línea convierte la tabla en matriz
Mat_Corr=corrcoef(Matriz) %Matriz de correlaciones
%Mapa de calor
figure(1)
h = heatmap(Mat_Corr)



%Graficos de dispersión

%price y minimum_nights
figure(2)
S1 = scatter(data3_clean,'price','minimum_nights');

%price y number_of_reviews
figure(3)
S2 = scatter(data3_clean,'price','number_of_reviews');

%price y reviews_per_month
figure(4)
S3 = scatter(data3_clean,'price','reviews_per_month');

%price y calculated_host_listings_count
figure(5)
S4 = scatter(data3_clean,'price','calculated_host_listings_count');

%price y availability_365
figure(6)
S5 = scatter(data3_clean,'price','availability_365');

%price y number_of_reviews_ltm
figure(7)
S6 = scatter(data3_clean,'price','number_of_reviews_ltm');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Regresión lineal-------------

%Las correlaciones mas altas obtenidas con price en nuestro modelo son
%number_of_reviews y reviews_per_month

%Variable number_of_reviews
x1=Matriz(:,3);
%Variable reviews_per_month
x2=Matriz(:,4);
%Variable price
y=Matriz(:,1);


%Variables independientes
X= [x1 x2];
%Variable dependiente
y= [y];
[b,~,~,~,stats] = regress(y,X);

%---------Predicción----------------

%Calcular predicción de columna total
total_Pred= b(1)*x1 + b(2)*x2;
%Agregar columna a tabla 
data3_final= addvars(data3_clean,total_Pred,'Before',"price");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Visualización-------------

%Scatter plot de 3 variables 
figure(8)
scatter3(x1,x2,y,'filled');
hold on;
x1fit = min(x1):0.5:max(x1);
x2fit = min(x2):0.5:max(x2);
[X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
YFIT = b(1)*X1FIT + b(2)*X2FIT;
mesh(X1FIT,X2FIT,YFIT);
xlabel('number_of_reviews');
ylabel('reviews_per_month');
zlabel('price');
view(30,10);
hold off

%Geobubble: Visualiza valores de datos en ubicaciones geográficas específicas

%Mapa de precios por tipo de cuartos
figure(8)
geobubble(data3_final,'latitude','longitude','SizeVariable','price','ColorVariable','room_type','Basemap','streets')
title 'México'

%Mapa de precios por vecindarios
figure(9)
geobubble(data3_final,'latitude','longitude','SizeVariable','price','ColorVariable','neighbourhood','Basemap','streets')
title 'México';


%Comparación por tipo de cuarto y el precio predecido con el modelo linal
%y el precio real

%Precio real
figure(10)
geobubble(data3_final,'latitude','longitude','SizeVariable','price','ColorVariable','room_type','Basemap','streets')
title 'México';

%Precio predecido
figure(11)
geobubble(data3_final,'latitude','longitude','SizeVariable','total_Pred','ColorVariable','room_type','Basemap','streets')
title 'México';


%Barras paralelas: Visualiza la relación entre 2 o mas variables

%Precio real
figure(12)
Mex_Vars= data3_final(:,[12,8,10])
parallelplot(Mex_Vars,'GroupVariable','room_type')
title 'Mexico';

%Precio predecido
figure(13)
Mex_Vars2= data3_final(:,[12,8,9])
parallelplot(Mex_Vars2,'GroupVariable','room_type')
title 'Mexico';



