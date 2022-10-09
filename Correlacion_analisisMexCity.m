%---------Mexico City---------
%---------Identificación de Nulos---------

%Identificamos la matriz de datos faltantes del DataFrame
Matriz_Null= ismissing(Mexico);

%Columnas con Nulos: neighbourhood y reviews_per_month
Column_Null= sum(Matriz_Null)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------Sustitución de Nulos---------

%Rellenamos datos faltantes por DataFrame usando diferentes métodos
data2 = fillmissing(Mexico2,'previous','DataVariables',{'neighbourhood','host_location','neighbourhood','bathrooms_text','first_review','last_review','host_is_superhost'});
data3 = fillmissing(data2,'movmean', 100,'DataVariable',{'reviews_per_month','host_acceptance_rate','host_response_rate','host_acceptance_rate','beds','bedrooms','review_scores_rating','review_scores_accuracy','review_scores_cleanliness','review_scores_checkin','review_scores_communication','review_scores_location','review_scores_value'});

%Identificamos la matriz de datos faltantes del DataFrame
Matriz_Null2= ismissing(data3);
%Columnas con Nulos
Column_Clean= sum(Matriz_Null2)

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

% La variable 'reviews_per_month' se sustituirá por el metodo linear
data3_outliers = filloutliers(data3,'linear','DataVariables',{'reviews_per_month'});

% Las variables 'minimum_minimum_nights','calculated_host_listings_count','number_of_reviews_ltm'
% se sustituiran por el metodo de center
data3_clean = filloutliers(data3_outliers,'center','DataVariables',{'minimum_minimum_nights', 'calculated_host_listings_count', 'number_of_reviews_ltm'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------Filtros de Datos---------

%Selecionamos solo las columnas numericas que necesitamos para hacer el
%análisis de correlaciones:

Filtro_Corre= data3_clean(:,[1,2,10,11,23,24,31,32,35,41,42,43,52,53,54,55,57,58,59,71,72,73,74,75,63,67]);

%---------Correlación de datos---------


%Matriz de correlaciones del Dataframe
Matriz=table2array(Filtro_Corre); %esta línea convierte la tabla en matriz
Mat_Corr=corrcoef(Matriz) %Matriz de correlaciones
%Mapa de calor
figure(1)
h = heatmap(Mat_Corr)

%Todas las correlaciones con la variable price son bajas, por lo que
%tomaremos las 2 correlaciones relativamente altas de las columnas
%minimum_nights y accommodates

%price y minimum_nights
figure(2)
S1 = scatter(data3_clean,'price','minimum_nights');

%price y accommodates
figure(3)
S2 = scatter(data3_clean,'price','accommodates');



%---------Regresión lineal-------------

%Las correlaciones mas altas obtenidas con price en nuestro modelo son
%accommodates (.0735)
%minimum_nights (.1029)


%Variable accommodates
x1=Matriz(:,9);
%Variable minimum_nights
x2=Matriz(:,11);
%Variable price
y=Matriz(:,10);


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
figure(4)
scatter3(x1,x2,y,'filled');
hold on;
x1fit = min(x1):0.5:max(x1);
x2fit = min(x2):0.5:max(x2);
[X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
YFIT = b(1)*X1FIT + b(2)*X2FIT;
mesh(X1FIT,X2FIT,YFIT);
xlabel('accommodates');
ylabel('minimum_nights');
zlabel('price');
view(30,10);
hold off

%Geobubble: Visualiza valores de datos en ubicaciones geográficas específicas

%Mapa de price por tipo de cuarto
figure(5)
geobubble(data3_final,'latitude','longitude','SizeVariable','price','ColorVariable','room_type','Basemap','streets')
title 'Bristol'

%Mapa de precios por baños 
figure(6)
geobubble(data3_final,'latitude','longitude','SizeVariable','price','ColorVariable','bathrooms_text','Basemap','streets')
title 'Bristol'

%Mapa de accommodates por tipo de cuarto
figure(7)
geobubble(data3_final,'latitude','longitude','SizeVariable','accommodates','ColorVariable','room_type','Basemap','streets')
title 'Bristol'

%Mapa de price por property_type
figure(8)
geobubble(data3_final,'latitude','longitude','SizeVariable','price','ColorVariable','property_type','Basemap','streets')
title 'Bristol'


%Comparación por tipo de cuarto y el precio predecido con el modelo linal
%y el precio real

%Precio real
figure(9)
geobubble(data3_final,'latitude','longitude','SizeVariable','price','ColorVariable','room_type','Basemap','streets')
title 'Bristol';

%Precio predecido
figure(10)
geobubble(data3_final,'latitude','longitude','SizeVariable','total_Pred','ColorVariable','room_type','Basemap','streets')
title 'Bristol';

%Barras paralelas: Visualiza la relación entre 2 o mas variables de nuestro

figure(11)
Bris_Vars= data3_final(:,[29,34,42])
parallelplot(Bris_Vars,'GroupVariable','room_type')
title 'Bristol';

figure(12)
Bris_Vars2= data3_final(:,[75,34,42])
parallelplot(Bris_Vars2,'GroupVariable','room_type')
title 'Bristol';
