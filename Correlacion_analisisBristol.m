%---------Bristol---------
%---------Identificación de Nulos---------

%Eliminamos las columnas que no ocuparemos y solo nos quedamos con las
%columnas mas relevates para el análisis
data= Bristol(:,[28,34,41,44,47,75,71,55,58,31,32,62,18]);

%Identificamos la matriz de datos faltantes del DataFrame
Matriz_Null= ismissing(data);

%Columnas con Nulos: neighbourhood y reviews_per_month
Column_Null= sum(Matriz_Null)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------Sustitución de Nulos---------

%Rellenamos datos faltantes por DataFrame usando diferentes métodos
data2 = fillmissing(data,'previous','DataVariables',{'neighbourhood'});
data3 = fillmissing(data2,'movmean', 100,'DataVariable',{'reviews_per_month','review_scores_rating','host_acceptance_rate'});

%Identificamos la matriz de datos faltantes del DataFrame
Matriz_Null2= ismissing(data3);
%Columnas con Nulos
Column_Null2= sum(Matriz_Null2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Identificación de Outliers---------

%Identificamos Matriz de outliers mediante método de desviación estándar
Outliers = isoutlier(data3,'mean','DataVariables',{'price','minimum_minimum_nights','maximum_maximum_nights','reviews_per_month','calculated_host_listings_count','availability_365','number_of_reviews_ltm','latitude','longitude'});
%Identificamos la cantidad de outliers por Columna
Column_outliers= sum(Outliers)
%Identificamos la cantidad de datos faltantes por DataFrame
Data_Outliers= sum(Column_outliers)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Sustitución de Outliers---------

% Las variables 'latitude' y 'longitude' tienen outliers, sin embargo al
% ser coordenadas si se sustituyen tendremos un error con los datos. Por lo
% tanto los dejaremos igual


% La variable 'reviews_per_month' se sustituirá por el metodo linear
data3_outliers = filloutliers(data3,'linear','DataVariables',{'reviews_per_month'});

% Las variables 'price', 'minimum_minimum_nights','calculated_host_listings_count','number_of_reviews_ltm',review_scores_rating,host_acceptance_rate
% se sustituiran por el metodo de center
data3_clean = filloutliers(data3_outliers,'center','DataVariables',{'price', 'minimum_minimum_nights', 'calculated_host_listings_count', 'number_of_reviews_ltm'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Filtros de Datos---------

%Selecionamos solo las columnas numericas que necesitamos para hacer el
%análisis de correlaciones:

Filtro_Corre= data3_clean(:,[3:9,12,13]);

%price 1
%minimum_minimum_nights 2
%maximum_maximum_nights 3
%reviews_per_month 4
%calculated_host_listings_count 5
%availability_365 6
%number_of_reviews_ltm 7
%review_scores_rating 8
%host_acceptance_rate 9

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
S1 = scatter(data3_clean,'price','minimum_minimum_nights');

%price y number_of_reviews
figure(3)
S2 = scatter(data3_clean,'price','maximum_maximum_nights');

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

%price y number_of_reviews_ltm
figure(8)
S7 = scatter(data3_clean,'price','review_scores_rating');

%price y number_of_reviews_ltm
figure(7)
S8 = scatter(data3_clean,'price','host_acceptance_rate');

%---------Regresión lineal-------------

%Las correlaciones mas altas obtenidas con price en nuestro modelo son
%review_scores_rating y host_acceptance_rate

%Variable review_scores_rating
x1=Matriz(:,8);
%Variable host_acceptance_rate
x2=Matriz(:,9);
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

%Scatter plot de 3 variables con nuestro modelo predecido
figure(8)
scatter3(x1,x2,y,'filled');
hold on;
x1fit = min(x1):0.5:max(x1);
x2fit = min(x2):0.5:max(x2);
[X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
YFIT = b(1)*X1FIT + b(2)*X2FIT;
mesh(X1FIT,X2FIT,YFIT);
xlabel('review_scores_rating');
ylabel('host_acceptance_rate');
zlabel('price');
view(30,10);
hold off

%Geobubble: Visualiza valores de datos en ubicaciones geográficas específicas

%Mapa de review_scores_rating por tipo de cuarto
figure(8)
geobubble(data3_final,'latitude','longitude','SizeVariable','review_scores_rating','ColorVariable','room_type','Basemap','streets')
title 'Bristol'

%Mapa de host_acceptance_rate por tipo de cuarto
figure(9)
geobubble(data3_final,'latitude','longitude','SizeVariable','host_acceptance_rate','ColorVariable','room_type','Basemap','streets')
title 'Bristol'

%Mapa de precios por tipo de cuarto
figure(10)
geobubble(data3_final,'latitude','longitude','SizeVariable','price','ColorVariable','room_type','Basemap','streets')
title 'Bristol'

%Comparación por tipo de cuarto y el precio predecido con el modelo linal
%y el precio real

%Precio real
figure(11)
geobubble(data3_final,'latitude','longitude','SizeVariable','price','ColorVariable','room_type','Basemap','streets')
title 'Bristol';

%Precio predecido
figure(12)
geobubble(data3_final,'latitude','longitude','SizeVariable','total_Pred','ColorVariable','room_type','Basemap','streets')
title 'Bristol';

%Barras paralelas: Visualiza la relación entre 2 o mas variables de nuestro
%modelo predecido y el real

%Precio predecido
figure(13)
Bris_Vars= data3_final(:,[13,2,3])
parallelplot(Bris_Vars,'GroupVariable','room_type')
title 'Bristol';

%Precio real
figure(14)
Bris_Vars2= data3_final(:,[14,2,4])
parallelplot(Bris_Vars2,'GroupVariable','room_type')
title 'Bristol';



