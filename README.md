# GDPbySectorShinyApp

(NOTE: THIS IS A SHINY APP. FOR IT TO WORK YOU MUST CREATE AN R DIRECTORY INCLUDING THE UI.R AND SERVER.R FILES, THEN SET THAT DIRECTORY TO BE YOUR WORKING DIRECTORY AND ENTER RUNAPP() ON THE R CONSOLE.) 

GDP by Sector Shiny App

The data for my app comes from the following two US National Income and Product Account (NIPA) tables:

Nominal table: http://www.bea.gov/iTable/iTable.cfm?ReqID=9&step=1#reqid=9&step=3&isuri=1&903=35
Real table: http://www.bea.gov/iTable/iTable.cfm?ReqID=9&step=1#reqid=9&step=3&isuri=1&903=36

These are table #'s 35 and 36, including detailed subcategories of nominal and real GDP.

The user has the option to select any sector available in the tables and any number of quarters up to 270, which means our data goes back to 1949. 

The App draws on the BEA's API and new data should be updated soon after new releases. 

The App has four charts once the user has chosen a sector to view and a number of quarters to see.

1. Nominal Growth: we show the chosen sector's quarterly annualized growth rate in each period. Also shown is a Loess trend including a confidence interval. Finally, we indicate the chosen sector's share of nominal GDP in the most recent quarter. This inclusion is actually one reason for creating this App. There are many options to view parts of GDP quickly, but getting a sense of how each component affects the overall GDP is difficult, because one must quickly go back and forth between weights or nominal levels and the growth rates. Here we show all this information on the same chart.

2. Real Growth: for the same sector we show the BEA's estimate for real (inflation-adjusted) growth rates using fixed prices. Again we indicate the share of (nominal) GDP in the current quarter. 

3. Nominal Growth vs. Trend: We show the natural log of the level of nominal GDP, a linear trend for the period chosen, and we indicate the slope of the linear trend. 

4. Real Growth vs. Trend: We show the natural log of an index of real GDP, a linear trend for the period chosen, and we indicate the slope of the linear trend. 

The purpose of this App is to help someone quickly peruse GDP data and gain a sense of what the key sectors are doing, how important that is for the overall GDP, and also whether real activity or nominal activity appears to be abnormally strong or weak in a given period based on growth rate and level trends. 

The links above to the BEA website will give more information on these measures.

Not all sectors are available for all periods possible, so in some cases the charts will not be available, but for the vast majority they will be. 
