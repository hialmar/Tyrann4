#labels
 REM |=====================================================|
 REM |=================||| OBJETS |||======================|
 REM |=====================================================|
 DIM ITEM$(38)
 O1=#A000
 POKEO1,38
 FOR I=1 TO 38
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
 DATA Lorica Segmantata, Lorica Squamata, Lorica Hamata, Leather Armor, Scutum, Linen Tunic:REM 1-6 
 DATA Gladius, Pilum, Hammer, Bow, Sling, Net, Pugio:REM 7-9 AC, 10-Bow, 11-Sling, 12-Net, 13-Pugio 
 DATA Unguent, Divine wood, Vital juice, Ebony Potion, Divine Potion, Freezing Potion
 DATA Wineskin, Loaf of bread, Ale, Dry fish, Boar leg, Crowbar, Compass
 DATA Wolf, Panther, Mastiff, Eagle, Hawk, Wild dog, Wild Cat
 DATA Crown, Jewel, Pearls, Diamonds, Pouch of coins