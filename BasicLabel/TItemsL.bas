#labels
 REM |=====================================================|
 REM |=================||| OBJETS |||======================|
 REM |=====================================================|
 DIM ITEM$(41)
 O1=#A000
 POKEO1,38
 FOR I=1 TO 41
 READ ITEM$(I):
 LG=LEN(ITEM$(I))
 O1=O1+1:POKEO1,LG
 IF LG=0 THEN  TItems_0 
 FOR J=1 TO LG
 O1=O1+1:POKEO1,ASC(MID$(ITEM$(I),J,1))
 NEXT
TItems_0
 NEXT
 PRINT"SAUVEGARDE DU TABLEAU"
 REM STORE ITEM$,"T-ITEMS",S
 SAVEO "TITEMS.BIN",A#A000,EO1
 PRINT"OBJETS OK":PING:ZAP:END
 DATA Lorica Segmantata, Lorica Squamata, Lorica Hamata, Lorica, Scutum, Tunica:REM 1-6 
 DATA Gladius, Spatha, Pilum, Fascina, Manu Ballista, Archus, Funda, Rete, Pugio:REM 7-10 AC, 11-CBow, 12-Bow, 13-Sling, 14-Net, 15-Pugio 
 DATA Unguent, Divine wood, Vital juice, Ebony Potion, Divine Potion, Visio Potion, Freezing Potion:REM 16-22
 DATA Wineskin, Loaf of bread, Ale, Dry fish, Boar leg, Crowbar, Compass:REM 23-29
 DATA Wolf, Panther, Canis molossus, Eagle, Hawk, Wild dog, Wild Cat:REM 30-36
 DATA Crown, Jewel, Pearls, Diamonds, Pouch of coins:REM 37-41