--1. Combien y-a-t-il d'enregistrements dans les tables DimCustomer,
--DimPromotion et DimCurrency ?
select count(*) from DimCustomer
--18484

select count(*) from DimCurrency
--105

select count(*) from DimPromotion
--16


--2. Lister par ville, par sexe et par ordre alphab�tique les clients habitant aux Etats
--Unis.
select DimGeography.City, Gender, LastName from DimCustomer
join DimGeography
on DimCustomer.GeographyKey = DimGeography.GeographyKey
where CountryRegionCode like 'US'
order by LastName asc


--3. Combien y en a-t-il ? (faire une requ�te)

select count(*) from DimGeography
where CountryRegionCode = 'US'
--376


--4. Quelle cat�gorie de produit a �t� la plus vendue ?

select max(FrenchProductCategoryName) from DimProductCategory
join DimProductSubcategory
on DimProductCategory.ProductCategoryKey = DimProductSubcategory.ProductCategoryKey
join DimProduct
on DimProductSubcategory.ProductSubcategoryKey = DimProduct.ProductSubcategoryKey
join FactInternetSales
on DimProduct.ProductKey = FactInternetSales.ProductKey
--V�tements


--5. Donner l�adresse compl�te de Shannon C Carlson.

select FirstName, MiddleName, LastName, AddressLine1, DimGeography.City, DimGeography.FrenchCountryRegionName from DimCustomer
join DimGeography
on DimCustomer.GeographyKey = DimGeography.GeographyKey
where FirstName = 'Shannon' and MiddleName = 'C' and LastName = 'Carlson'


--6. Pour l�ann�e 2011, quelle zone de vente a �t� la plus productive en nombre de
--vente ? M�me question en chiffre d�affaire ?

select max(SalesTerritoryRegion) from DimSalesTerritory
join FactInternetSales
on DimSalesTerritory.SalesTerritoryKey = FactInternetSales.SalesTerritoryKey
join DimDate
on FactInternetSales.ShipDateKey = DimDate.DateKey
where FiscalYear = 2011
--United Kigdom

--6. version chiffre d'affaire
select max(SalesTerritoryRegion) from DimSalesTerritory
join FactInternetSales
on DimSalesTerritory.SalesTerritoryKey = FactInternetSales.SalesTerritoryKey
join DimDate
on FactInternetSales.ShipDateKey = DimDate.DateKey
where SalesAmount = (select max(SalesAmount) from FactInternetSales)
--United Kingdom


--7. S�lectionner les clients (customerName) qui n'ont pas encore pass� commande
--et trier par ordre alphab�tique ascendant.
select LastName, MiddleName, FirstName from ProspectiveBuyer
order by LastName asc


--8. Combien de VTT ont �t� vendu depuis le d�but
select count(FrenchProductSubcategoryName) from DimProductSubcategory
join DimProduct
on DimProductSubcategory.ProductSubcategoryKey = DimProduct.ProductSubcategoryKey
join FactResellerSales
on DimProduct.ProductKey = FactResellerSales.ProductKey
where FrenchProductSubcategoryName = 'VTT'
--7487


--9. Combien y-a-t-il de villes diff�rentes dans la table DimCustomer?
select count(distinct city) from DimCustomer
join DimGeography
on DimCustomer.GeographyKey = DimGeography.GeographyKey
--269


--10. Les casques sport ne se vendent pas bien. On souhaite modifier la promotion en
--cours. Passer celle-ci de 15% � 30%.

update DimPromotion
set DiscountPct = '0.30'
where FrenchPromotionName like '% casques %'


--11. Ecrire un d�clencheur permettant d�ajouter une promotion lorsqu�on ajoute un
--nouvel article. La promotion se fait comme suit :
--- Nom de la promotion : Nouveau produit
--- R�duction : 15%
--- Type de promotion : Client
--- Commence � partir de maintenant pour 5 ans
--- La promotion se d�clenche � partir de 5 articles command�s

create trigger PROMOECF
on DimProduct
for insert
as
begin
    Insert into DimPromotion (FrenchPromotionName, DiscountPct, FrenchPromotionType, StartDate, EndDate, MinQty)
    values ('Nouveau Produit', 0.15, 'Client', getdate(), getdate()+5*365, 5)
end


--12. Tester le d�clencheur en ajoutant un article coh�rent. insert into DimProduct(EnglishProductName, SpanishProductName, FrenchProductName, FinishedGoodsFlag, Color)values ('pedals backwards', 'pedales al rev�s', 'p�dales � l''envers', 'False', 'NA') 