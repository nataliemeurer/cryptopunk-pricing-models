# Basic script to transform rarity_data.json to punk_rarities.csv
# R tends to be better at processing data frames, so we preprocessed
# using the code below.

import json
import csv

rarity_file = open("rarity_data.json")
rarity = json.load(rarity_file)

rows = [["id",
         rarity["basePropDefs"][1]["name"],
         rarity["basePropDefs"][1]["name"]+"-rarity",
         
         rarity["basePropDefs"][2]["name"],
         rarity["basePropDefs"][2]["name"]+"-rarity",
         
         rarity["basePropDefs"][3]["name"],
         rarity["basePropDefs"][3]["name"]+"-rarity",
         "isPersonOfColor",
         
         rarity["basePropDefs"][4]["name"],
         rarity["basePropDefs"][4]["name"]+"-rarity",
         
         rarity["basePropDefs"][5]["name"],
         rarity["basePropDefs"][5]["name"]+"-rarity",
         
         rarity["basePropDefs"][6]["name"],
         rarity["basePropDefs"][6]["name"]+"-rarity",
         
         rarity["basePropDefs"][7]["name"],
         rarity["basePropDefs"][7]["name"]+"-rarity",
         
         rarity["basePropDefs"][8]["name"],
         rarity["basePropDefs"][8]["name"]+"-rarity",
         
         rarity["basePropDefs"][9]["name"],
         rarity["basePropDefs"][9]["name"]+"-rarity",
         
         rarity["basePropDefs"][10]["name"],
         rarity["basePropDefs"][10]["name"]+"-rarity",
         
         rarity["basePropDefs"][11]["name"],
         rarity["basePropDefs"][11]["name"]+"-rarity",
         
         rarity["basePropDefs"][12]["name"],
         rarity["basePropDefs"][12]["name"]+"-rarity",
         
         rarity["basePropDefs"][13]["name"],
         rarity["basePropDefs"][13]["name"]+"-rarity",
         ]]

for idx, punk in enumerate(rarity["items"]):
    new_punk = []
    new_punk.append(punk[0]) # id
    
    
    new_punk.append(rarity["basePropDefs"][1]["pvs"][punk[1]][0])
    new_punk.append(1/ (rarity["basePropDefs"][1]["pvs"][punk[1]][1] / 10000))
    
    new_punk.append(rarity["basePropDefs"][2]["pvs"][punk[2]][0])
    new_punk.append(1/ (rarity["basePropDefs"][2]["pvs"][punk[2]][1] / 10000))
    
    skin_tone = rarity["basePropDefs"][3]["pvs"][punk[3]][0]
    new_punk.append(skin_tone)
    new_punk.append(1/ (rarity["basePropDefs"][3]["pvs"][punk[3]][1] / 10000))
    new_punk.append(1 if skin_tone in ["Dark", "Mid"] else 0)
    
    new_punk.append(rarity["basePropDefs"][4]["pvs"][punk[4]][0])
    new_punk.append(1/ (rarity["basePropDefs"][4]["pvs"][punk[4]][1] / 10000))
    
    new_punk.append(rarity["basePropDefs"][5]["pvs"][punk[5]][0])
    new_punk.append(1/ (rarity["basePropDefs"][5]["pvs"][punk[5]][1] / 10000))
    
    new_punk.append(rarity["basePropDefs"][6]["pvs"][punk[6]][0])
    new_punk.append(1/ (rarity["basePropDefs"][6]["pvs"][punk[6]][1] / 10000))
    
    new_punk.append(rarity["basePropDefs"][7]["pvs"][punk[7]][0])
    new_punk.append(1/ (rarity["basePropDefs"][7]["pvs"][punk[7]][1] / 10000))
    
    new_punk.append(rarity["basePropDefs"][8]["pvs"][punk[8]][0])
    new_punk.append(1/ (rarity["basePropDefs"][8]["pvs"][punk[8]][1] / 10000))
    
    new_punk.append(rarity["basePropDefs"][9]["pvs"][punk[9]][0])
    new_punk.append(1/ (rarity["basePropDefs"][9]["pvs"][punk[9]][1] / 10000))
    
    new_punk.append(rarity["basePropDefs"][10]["pvs"][punk[10]][0])
    new_punk.append(1/ (rarity["basePropDefs"][10]["pvs"][punk[10]][1] / 10000))
    
    new_punk.append(rarity["basePropDefs"][11]["pvs"][punk[11]][0])
    new_punk.append(1/ (rarity["basePropDefs"][11]["pvs"][punk[11]][1] / 10000))
    
    new_punk.append(rarity["basePropDefs"][12]["pvs"][punk[12]][0])
    new_punk.append(1/ (rarity["basePropDefs"][12]["pvs"][punk[12]][1] / 10000))
    
    new_punk.append(rarity["basePropDefs"][13]["pvs"][punk[13]][0])
    new_punk.append(1/ (rarity["basePropDefs"][13]["pvs"][punk[13]][1] / 10000))
    rows.append(new_punk)

with open('punk_rarities.csv', 'w', newline='') as csvfile:
    punkwriter = csv.writer(csvfile, delimiter=',',
                            quotechar='"', quoting=csv.QUOTE_MINIMAL)
    for row in rows:
        punkwriter.writerow(row)


