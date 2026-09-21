
/*cerinta 3.2.1  -- select 1
  WHERE + operatori: creați un raport cu ticketele deschise în 2026 folosind BETWEEN pentru 
  intervalul de date și IN pentru Status IN ('OPEN','In Progress','Pending','Reopened'). 
  Afișați TicketID, OpenDateTime, Status, PriorityID, TeamID și AgentID și ordonați descrescător 
  după OpenDateTime */

select * from DimAgent 

select * from FactTickets ;

select TicketID , OpenDateTime , Status , PriorityID , TeamID , AgentID
from FactTickets
where OpenDateTime between '2026-01-01' and '2026-12-31'
and Status in ('OPEN','In Progress','Pending','Reopened')
order by OpenDateTime desc ;



/* cerinta 3.2.1 --select 2 
 Utilizati LIKE impreuna cu AND/OR pt filtrarea unui camp relevant 
 si IS NULL /IS NOT NULL pt verificarea unui camp optional  */


select * from FactTickets;


select TicketID ,
       Status ,
       UserDescription ,
       ResolutionCode
from FactTickets
where (UserDescription like '%started% ' or UserDescription like 'p%') 
       and ResolutionCode is not null ;


/* cerinta 3.2.2
GROUP BY + functii de agregare : creati trei rapoarte 
(1) COUNT(TicketID) pt fiecare Status */ -- 

select * from FactTickets;

select CustomerID , 
       ResolutionCode ,
       status ,  
       count(TicketID) as nr_tichete 
from FactTickets
group by CustomerID ,  status ,ResolutionCode ; 


/* cerinta 3.2.2
GROUP BY + functii de agregare : creati trei rapoarte 
(3) COUNT(TicketID)si pt un camp numeric relevant  , SUM/AVG unde este logic aplicabil pt fiecare TeamID  

Numarul de tichete si suma transferurilor pt fiecare TeamID */


select * from FactTickets;

select count(*) as Total_Rows
from FactTickets ;

select TeamID , 
       count(TicketID ) as Numar_Tichete , 
       sum(TransferCount) as Total_Transferuri 
from FactTickets
group by TeamID ;

select count(*) as Ticket_ID_NULL
from FactTickets
where TicketID is null ;



/* cerinta 3.2.3
HAVING +comparatii : grupati FactTickets pe AgentID si afisati numai agentii cu COUNT(TicketID) > un prag ales si justificat . */

select TransferCount from FactTickets

select AgentID , 
       count(TicketID) as Numar_tichete , 
       avg(cast(TransferCount as Float )) as Medie_transferuri
       from FactTickets 
group by AgentID
having count (TicketID) > 1000 
order by Numar_tichete desc ;

-- am ales pragul de 1000 tichete pt a identifica agentii cu un volum ridicat de activitate 


/* cerinta 3.3
JOIN -uri si integrarea modelului 
3.3.1 INNER JOIN :
Creati un raport din care sa se obtina numarul de tichete pt fiecare agent , alaturand FactTickets si DimAgent. 
AfisatiAgentID , AgentName ,TeamID si numarul de tichete */ 

select * from DimAgent ; --da
select * from FactTickets ;  -- ft

select da.AgentID ,
       da.AgentName ,
       da.TeamID ,
       count(ft.TicketID) as nr_tichete 
from DimAgent da 
join FactTickets ft 
  on da.AgentID = ft.AgentID
group by da.AgentID ,
         da.AgentName ,
         da.TeamID ;


/* 3.3.2 LEFT JOIN :
Creati un raport care 
afiseaza toti agentii din DimAgent si 
numarul de tichete asociate fiecaruia , inclusiv agentii care nu au niciun tichet  */

select * from DimAgent ; --da
select * from FactTickets ;  -- ft

select da.AgentID , 
       da.AgentName ,
       count(ft.TicketID) as nr_tichete 
from DimAgent da
left join FactTickets ft 
 on da.AgentID  = ft.AgentID
group by da.AgentID , 
       da.AgentName 
order by nr_tichete ;

/* 3.3.3 JOIN suplimentar + verificarea granularitatii :
utilizati un al 3 lea tip de JOIN pentru a verifica existenta unor inregistrari fara corespondent intre doua tabele alese . 
Comparati nr de randuri inainte si dupa JOIN si explicati in comentarii 
daca rezulatul pastreaza granularitatea asteptata . */

select * from DimTeam ; --dt
select * from FactTickets ;  -- ft

select ft.TeamID as TeamID_Fact,
       dt.TeamID as TeamID_Dim ,
       ft.TicketID , 
       dt.TeamName 
from FactTickets ft 
full outer join DimTeam dt
 on ft.TeamID = dt.TeamID
where ft.TeamID is null or dt.TeamID is null ;

-- FULL OUTER JOIN nu a a returnat randuri fara corespondent 
-- toate valorile TeamID din FactTickets au corespondent in DimTeam 
-- Toate echipele din DimTeam sunt asociate cu cel putin un tichet */

--numarul de randuri inainte si dupa JOIN 

select count(*) as Randuri_FactTickets
from FactTickets ;

select count(*) as nr_randuri_dupa_join 
from FactTickets ft 
left join DimTeam dt
 on ft.TeamID = dt.TeamID ;
 
-- concluzie : granularitatea la nivel de tichet s-a pastrat 


/* 3.4 CTE si subinterogari 

3.4.1 
CTE 1 : Calculati pt fiecare echipa numarul de tichete si timpul mediu de rezolvare , apoi utilizati rezultatul CTE -ului 
        pt a afisa echipele ordonate dupa performanta */

select * from DimTeam ;--dt
select * from FactTickets ;--ft 

with performanta_echipa  as (
select dt.TeamID ,dt.TeamName ,
       count(ft.TicketID) as numar_tichete ,
       avg(cast(datediff(minute, ft.OpenDateTime ,ft.ResolvedDateTime) as float ))/60 as timp_mediu_de_rezolvare_ore
from FactTickets as ft
join DimTeam as dt 
  on dt.TeamID = ft.TeamID
where ft.ResolvedDateTime is not null 
group by dt.TeamID ,dt.TeamName)

select TeamID, TeamName ,numar_tichete , timp_mediu_de_rezolvare_ore
from performanta_echipa 
order by timp_mediu_de_rezolvare_ore  ; 

/* 3.4.2 
CTE 2 : Calculati pentru fiecare categorie volumul de tichete si rata de reopen si utilizati rezultatul intr-un raport separat */ 

select * from FactTickets ; --ft 
select * from DimCategory ; --dc 

with volum_de_tichete as (
select dc.Categoryid, 
       dc.CategoryName ,
       count(ft.TicketID) as nr_tichete , 
       avg(cast(ft.ReopenCount as float))as rata_reopen  
from DimCategory dc 
join FactTickets ft 
  on dc.CategoryID = ft.CategoryID 
group by dc.CategoryID, 
       dc.CategoryName )

select CategoryName , nr_tichete ,rata_reopen
from volum_de_tichete
order by nr_tichete ; 


/* 3.4.3
Subinterogare : Identificati agentii al caror numar de tichete este mai mare decat media numarului de tickete gestionate 
de toti agentii */

select * from DimAgent ;      --da
select * from FactTickets ;   --ft 

-- nr tichete pe fiecare agent   
with nr_tichete_agent  as (
select AgentID , 
       count(TicketID) as nr_tichete_agent 
from FactTickets 
group by AgentID)

-- nr tichete pe fiecare agent > media tichetelor 
select da.AgentID,
       da.AgentName,
       nta.nr_tichete_agent
from DimAgent da
join nr_tichete_agent nta
  on da.AgentID = nta.AgentID
where nta.nr_tichete_agent > (select avg(nr_tichete_agent) 
                        from nr_tichete_agent)
order by nr_tichete_agent desc ;




/* 3.5 UNION/UNION ALL 
3.5.1  construiți două SELECT-uri cu aceeași structura: unul pentru ticketele cu status Resolved și unul pentru 
       ticketele cu status Cancelled; combinați-le într-un singur rezultat 
       care conține TicketID, Status, CategoryID, PriorityID și data ultimei modificari. */

select * from FactTickets ;

select TicketID , Status ,CategoryID, PriorityID
from FactTickets 
where Status = 'Resolved';

select TicketID , Status , CategoryID, PriorityID
from FactTickets 
where Status = 'Cancelled' ;


select TicketID , Status ,CategoryID, PriorityID
from FactTickets 
where Status = 'Resolved'
union all 
select TicketID , Status , CategoryID, PriorityID
from FactTickets 
where Status = 'Cancelled'

-- Am folosit UNION ALL , pastreaza toate randurile si nu elimina duplicatele 


/* 3.6. Window Functions și istoricul ticketelor 
Utilizați FactTicketEvents pentru următoarele analize obligatorii:

3.6.1 ROW_NUMBER: numerotați cronologic evenimentele fiecărui ticket folosind funcția ROW_NUMBER, partiționată după TicketID 
                  și ordonată după EventDateTime. */

select * from FactTicketEvents ;

select TicketID , 
       EventID , 
       EventType , 
       EventDateTime ,
       ROW_NUMBER() over (partition by TicketID order by EventDateTime ) as nr_evenimente 
from FactTicketEvents 
order by TicketID ,nr_evenimente ;


/* 3.6.2 LAG/LEAD: pentru fiecare eveniment, afișați statusul/evenimentul anterior sau următor al aceluiași ticket și calculați, acolo unde este posibil, 
                   intervalul de timp dintre evenimente consecutive. */


select * from FactTicketEvents ;

select ticketID , 
       EventID ,
       EventType ,
       EventDateTime , 
       NewStatus,
       LAG(NewStatus) over (partition by TicketID order by EventDateTime ) as status_anterior , 
       LAG(EventDateTime)  over (partition by TicketID order by EventDateTime) as data_anterior ,
       LEAD(NewStatus) over (partition by TicketID order by EventDateTime ) as status_urmator , 
       LEAD(EventDateTime)  over (partition by TicketID order by EventDateTime) as data_urmator ,
       DATEDIFF (MINUTE ,LAG(EventDateTime) over (partition by TicketID order by EventDateTime),EventDateTime)  as diferenta_minute
       
from FactTicketEvents 
order by TicketID ;

/* 3.6.3 
Reopen: creați un raport cu TicketID și numărul de evenimente Reopened și afișați numai ticketele care au fost redeschise 
        cel puțin o dată 
        Utilizați FactTicketEvents */


select * from FactTicketEvents ;

select TicketID , 
       count(NewStatus) as nr_reopen 
from FactTicketEvents 
where NewStatus = 'Reopened'
group by TicketID 
having count (NewStatus) > =1
order by nr_reopen desc ;


/* 3.6.4 
 Pending: calculați pentru ticketele care au trecut prin Pending durata dintre evenimentul Pending și următorul Work Resumed, 
          acolo unde perechea de evenimente există.  */ 
 
 select * from FactTicketEvents ;

 with evenimente as (
  select ticketID ,
         eventType , 
         eventdateTime ,
         lead(EventType) over (partition by TicketID order by EventDateTime ) as eveniment_urmator, 
         lead(EventDateTime ) over (partition by TicketID order by EventDateTime) as data_urmatoare 
 from FactTicketEvents)

 select TicketID , 
        EventDateTime as data_pending , 
        data_urmatoare as data_work_resumed,
        DATEDIFF( minute , eventDateTime , data_urmatoare) as durata_pending_minute 
        from evenimente 
 where EventType = 'Pending' and eveniment_urmator = 'Work Resumed' ; 




 /* 3.7  Pregatirea sursei pt PowerBI 
 Pregătiți în SQL tabela FactTickets pentru utilizarea ulterioară în Power BI. 
 Nu adăugați în FactTickets atribute descriptive din tabelele dimensionale (de exemplu AgentName, TeamName, CategoryName, PriorityName). 
 Aceste tabele vor fi importate separat în Power BI și relaționate în modelul de date.

 3.7.1 
 Calculul duratelor (2 p)
 Creați un query care păstrează granularitatea de un rând per TicketID și calculează cu DATEDIFF() următoarele coloane:
 FirstResponseMinutes = numărul de minute dintre OpenDateTime și FirstTouchDateTime;
 ResolutionHours = numărul de ore dintre OpenDateTime și ResolvedDateTime;
 ResolutionDays = numărul de zile dintre OpenDateTime și ResolvedDateTime;
 TimeToCloseDays = numărul de zile dintre ResolvedDateTime și ClosedDateTime.
 Tratați explicit situațiile în care una dintre datele necesare calculului este NULL. În aceste situații, indicatorul calculat trebuie să rămână NULL */

 select * from FactTickets ;

 select TicketID ,
        OpenDateTime, 
        FirstTouchDateTime , 
        ResolvedDateTime,
        ClosedDateTime , 
        DATEDIFF( minute ,OpenDateTime , FirstTouchDateTime ) as FirstRespondMinutes ,
        DATEDIFF( hour , OpenDateTime , ResolvedDateTime ) as ResolutionHours , 
        DATEDIFF( day , OpenDateTime , ResolvedDateTime) as ResolutionDays , 
        DATEDIFF ( day , ResolvedDateTime , ClosedDateTime) as TimeToCloseDay 
 from FactTickets ;

 /* 3.7.2 
 Crearea indicatorilor de analiză (1 p)
În același query, utilizați CASE WHEN pentru a crea minimum următorii indicatori:
IsClosed – 1 dacă statusul curent este Closed, altfel 0;
IsCancelled – 1 dacă statusul curent este Cancelled, altfel 0;
IsCurrentlyOpen – 1 dacă ticketul se află în OPEN, In Progress, Pending sau Reopened, altfel 0.
Păstrați în rezultat și cheile dimensionale existente în FactTickets, precum AgentID, TeamID, CategoryID, SubcategoryID, PriorityID, ChannelID, SLAID etc. 
Nu le înlocuiți cu denumirile din dimensiuni. */


select * from FactTickets ;

select TicketID , 
       customerID , 
       OpenDateTime , 
       FirstTouchDateTime , 
       ResolvedDateTime ,
       ClosedDateTime , 
       Status , 
       PriorityID,
       CategoryID , 
       SubcategoryID , 
       ChannelID , 
       TeamID, 
       AgentID,
       SLAType,

       CASE
           when Status ='Closed' 
            then 1 
            else 0
       END  as IsClosed,

       CASE
          when Status = 'Cancelled'
           then 1
           else 0 
       END as IsCancelled ,

       CASE 
         when Status in ('OPEN','In Progress' , 'Pending' , 'Reopened')
          then 1
          else 0
       END as IsCurrentlyOpen 

from FactTickets ;




  /* 3.7.3
  Validarea rezultatului pentru Power BI (1 p)
Executați query-ul final și verificați că:
1.există un singur rând pentru fiecare TicketID;
2.numărul de rânduri rezultat este egal cu numărul de tickete valide din FactTickets;
3.coloanele calculate au valori numai atunci când datele necesare calculului există;
4.cheile dimensionale necesare construirii relațiilor în Power BI sunt păstrate.
Salvați query-ul în secțiunea „3.7 – Power BI Source” a scriptului SQL și includeți screenshot-ul obligatoriu al execuției complete, conform regulilor generale de documentare SQL. */

select * from FactTickets ;

-- querry final pt PowerBI 

select TicketID , 
       CustomerID,
       OpenDateTime ,
       FirstTouchDateTime ,
       ResolvedDateTime ,
       ClosedDateTime,
       Status,
       PriorityID,
       CategoryID,
       SubcategoryID,
       ChannelID,
       TeamID,
       AgentID,
       SLAType,

       CASE
        WHEN OpenDateTime IS NULL OR FirstTouchDateTime IS NULL THEN NULL
        ELSE DATEDIFF(MINUTE, OpenDateTime, FirstTouchDateTime)
    END AS FirstResponseMinutes,

    CASE
        WHEN OpenDateTime IS NULL OR ResolvedDateTime IS NULL THEN NULL
        ELSE DATEDIFF(HOUR, OpenDateTime, ResolvedDateTime)
    END AS ResolutionHours,

    CASE
        WHEN OpenDateTime IS NULL OR ResolvedDateTime IS NULL THEN NULL
        ELSE DATEDIFF(DAY, OpenDateTime, ResolvedDateTime)
    END AS ResolutionDays,

    CASE
        WHEN ResolvedDateTime IS NULL OR ClosedDateTime IS NULL THEN NULL
        ELSE DATEDIFF(DAY, ResolvedDateTime, ClosedDateTime)
    END AS TimeToCloseDays,

    CASE WHEN Status = 'Closed' THEN 1 ELSE 0 END AS IsClosed,
    CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END AS IsCancelled,
    CASE 
        WHEN Status IN ('OPEN', 'In Progress', 'Pending', 'Reopened') THEN 1
        ELSE 0
    END AS IsCurrentlyOpen

FROM FactTickets;

/* 3.7  Validarea rezultatului pentru PowerBI 

1.verificare : Exista un singur rand pentru fiecare TicketID */

select TicketID , 
       count(*) as nr_randuri 
from FactTickets 
group by TicketID 
having count(*) > 1 ;

-- concluzie :
-- nu returneaza nimic , deci FactTicketID apare o singura data 

/*
2. verificare : numărul de rânduri rezultat este egal cu numărul de tickete valide din FactTickets */

select count(*) as nr_tichete 
from FactTickets ;

-- concluzie :
-- dupa curatare raman 50000 randuri 

/*  3. coloanele calculate au valori numai atunci când datele necesare calculului există;(verificare NULL) */

select TicketID , 
       OpenDateTime,
       ResolvedDateTime,
       CASE
           WHEN OpenDateTime is null  OR  ResolvedDateTime is null THEN NULL 
           ELSE datediff( hour , OpenDateTime ,ResolvedDateTime )
       END as ResolutionHours
from FactTickets
where ResolvedDateTime is null ;

-- concluzie :
-- Pentru tichetele unde ResolvedDateTime este NULL , coloana calculata ResolutionHours ramane NULL 

/* Concluzie finala :
1. Exista un singur rand pt fiecare TicketID 
2. Dupa curatare raman 50000 randuri , adica numarul de randuri = nr de tichete valide din tabela 
   FactTickets 
3. Indicatorii de durata raman NULL cand lipsesc  datele implicate in calcul 
4. Cheile dimensionale necesare construirii relatiilor in PowerBI sunt pastrate */




select TABLE_NAME,
       COLUMN_NAME ,
       DATA_TYPE,
       CHARACTER_MAXIMUM_LENGTH,
       IS_NULLABLE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME LIKE 'Dim%'
order by TABLE_NAME ,
ORDINAL_POSITION ;

select * from DimTeam ;

select MAX(CapacityTicketsPerDAy) 
from DimTeam ;


SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME IN (
    'AgentID',
    'TeamID',
    'CategoryID',
    'SubcategoryID',
    'PriorityID',
    'ChannelID'
)
ORDER BY COLUMN_NAME, TABLE_NAME;

select * 
from DimCategory
where CategoryID ='C01' ;



select CategoryID, 
       count(*) as nr_aparitii 
from DimCategory
group by CategoryID
having count(*) >1 ; 


select * 
from FactTickets 
where status in  ('Resolved' )                                                                                                      