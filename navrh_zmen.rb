# coding: utf-8
# 
# **********************************************************
# VELKÝ REFACTORING GEMU ecb_rates SMĚREM K VERZI 1.0.0
# **********************************************************
# 
# HLAVNÍ PROBLÉMY A NAVRHOVANÉ ZMĚNY:
# 
# 1. Ukázkový kód z README souboru verze 0.1.0 na mém stroji
# po instalaci gemu nechodí, ačkoliv rspec testy procházejí
# a XML soubory ECB jsou z mého počítače online dostupné.
# Řešení: NAPRAVIT TAK ABY VŠECHNO CHODILO
# 
# 2. Třída EcbRates::Application je přílišným krokem ve směru
# objektové orientace.
# Řešení: ODSTRANIT A NAHRADIT FUNKČNÍM PROGRAMOVÁNÍM PŘÍMO
#         NA MODULU EcbRates
# 
# 3. Třídu EcbRates::ExchangeRates nahradit třídou
# EcbRates::Sheet reprezentující kurzovní lístek pro daný
# den. Příliš rozvláčný výraz
# ExchangeRates#exchange_rate_for(currency, rate) nahradit
# dvěma konstruktory EcbRates::Sheet.today a
# EcbRates::Sheet.day(datum).
# 
# 4. Na třídě Sheet implementovat metodu #currency,
# takže celková syntax bude
# EcbRates::Sheet.today.currency(:JPY) a
# EcbRates::Sheet.day('2016-07-10').currency(:JPY).
# 
# 5. Inštanční metodu Sheet#currency využít k
# metaprogramování metod odpovídajících zkratkám měn,
# takže by bylo možné psát EcbRates::Sheet.today.JPY,
# EcbRates::Sheet.today.GBP,
# EcbRates::Sheet.day('2016-07-10').USD
# 
# 6. Konstruktory .today a .day delegovat přímo z
# EcbRates, takže finální syntax pro uživatele bude
# EcbRates.today.JPY a EcbRates.day(datum).JPY
# 
# 7. Metoda EcbRates.exchange_rate si zachová své
# chování pro kompatibilitu, i když její chování ve
# verzi 0.1.0 se mi nelíbí kvůli tomu, že závisí na
# testu jestli se datum kurzovního lístku rovná
# Date.today, což může selhat když hodiny na uživatelském
# stroji nejsou nastaveny stejně jako hodiny v ECB
# (například proto, že uživatel je v jiném časovém
# pásmu). Místo toho bude Sheet.today konstruktor
# dávat varování když Date.today != ECB datum.
#
# 8. Soubor config.rb integrovat přímo do ecb_rates.rb --
# vzhledem k malé velikosti gemu to zvýší srozumitelnost.
#
# **********************************************************
