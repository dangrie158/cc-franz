###Mechanical Engineering
with eBay links – no affiliate, we do it all for love

#####BOM (What you need)
(inches are rounded to the closest fraction, everything was ordered in mm)

| Qty | Name                                | Dimensions                                     | Price                     |
|-----|-------------------------------------|------------------------------------------------|---------------------------|
| 2   | [aluminum sheet](http://www.ebay.de/itm/Alublech-1-5-mm-Aluminium-Tafel-Aluminiumlech-Alu-Zuschnitt-Grose-wahlbar-/111703985176?var=&hash=item1a02138c18)                      | 300mm x 200mm x 2mm – 11¾ in x 7¾ in x 80 mils | ~ 2,39€ pc.               |
| 2   | [linear bushing](http://www.ebay.de/itm/SC8UU-SCS8UU-Linearlager-Linearwagen-Linearschlitten-Linear-Motion-Ball-Bearing-/351361591099?hash=item51cec8673b)          |                                                | ~ 3,45€ pc.               |
| 2   | [linear shaft](http://www.ebay.de/itm/Prazisionswelle-8-mm-100-990mm-wahlbar-17-m-Tol-h6-geschliffen-cf53-1507-/390374537633?var=&hash=item5ae422b9a1)                       | 600mm x ∅8mm – 23⅔ in x ∅8mm                   | ~ 10,20€ pc.              |
| 4   | [shaft holder](http://www.ebay.de/itm/Wellenhalter-SH8-SH10-SH12-SH20-Welle-Linear-Rail-Shaft-Industrie-CNC-/151237551016?var=&hash=item233675e3a8)                | ∅8mm                                           | ~ 3,30€ pc.               |
| 1   | [aluminum profile](http://www.ebay.de/itm/ALU-Profil-Aluprofil-30x30-Nut-8-Profile-Aluminium-AlClipTec-/381199654414?var=&hash=item58c1451e0e)                    | 30mm x 30mm x 400mm – 1⅛ in x 1⅛ in x 15¾ in   | ~ 2,76€ pc.               |
| 1   | [jointed arm](http://www.ebay.de/itm/Gelenk-mit-Klemmhebel-fur-30x30-Aluprofil-/260979085629?hash=item3cc390d13d) (for camera attachment) | 30mm x 30mm – 1⅛ in x 1⅛ in                    | ~ 16,90€ pc.              |
| 2   | [stepper motor](http://www.ebay.de/itm/Schrittmotor-Stepper-Motor-Nema17-42BYGHW811-4800g-cm-2-5-A-3D-Drucker-RepRap-/261825775758?hash=item3cf608488e)            |                                                | ~ 14,90€ pc.              |
| 4   | [stands](http://www.ebay.de/itm/4x-Gelenkstellfusse-Stellfusse-fur-30x30-40x40-Alu-Profil-Aluprofil-Stellfuss-/291379384790?hash=item43d79091d6)                              | M8                                             | ~ 3,22€ pc.               |
| 1   | [GT2 belt](http://www.ebay.de/itm/Riemen-GT2-Open-Belt-Meterware-Zahnriemen-3D-Drucker-CNC-RepRap-/171898713404?hash=item2805f6353c)                            | 1m - 40 in                                     | ~ 2,20€ pc.               |
| 2   | [GT2 pulley](http://www.ebay.de/itm/Zahnrad-Pulley-GT2-20-Zahne-fur-5mm-Welle-CNC-RepRap-3D-Drucker-Prusa-/181838550576?hash=item2a566c1630)                          |                                                | ~ 2,90€ pc.               |
| 1   | [small turntable](http://www.ebay.de/itm/Drehteller-70x70mm-Drehlager-Drehtablett-Drehplatte-Flanschlager-Druckkugellager-/131458159153?hash=item1e9b845231)                     | 70mm x 70mm - 2¾ in x 2¾ in                    | ~ 2,58€ pc.               |
|     | Nuts and bolds                      | (M8, M6, M4, M3 and probably a couple more..)  | ~ 20€                     |
|     |                                     | **Total costs for mechanical parts:**              | **~ 138.20€ + shipping fees** |

#####Machining the parts
To connect all the parts we used the 2mm sheet metal. Since we had access to a CNC milling machine, we created CAD drawings for most of the parts. All holes are included in the drawings, however if you are missing small enough end mills, like we did, you might have to drill some of the holes manually. It comes in handy to print the drawing at 100% final scale and tape it on the milled part using scotch tape. This way, you can use the marked centers to spot the holes before drilling.


Every drawing requires to be milled one time.
The only parts not available as a drawing are the two aluminum profile sides, where all the plates are attached to. The drawings are currently optimized to a 160mm wide slider. If you want a broader slider to get a little more stability, you need to modify the bottom side of the turntable fixture first.

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/hand_drawing.jpg" alt="Hand Drawing" style="width: 500px;"/>

#####List of Drawings

| Name                         | Description                                                                      |
|------------------------------|----------------------------------------------------------------------------------|
| motor attachment.dwg         | attachment for a Nema17 motor, for the linear axis                               |
| pulley attachment.dwg        | attachment for a GT2 pulley, as the other side of the linear axis motorization   |
| turntable fixture bottom.dwg | attachment for the 2 SCS8UU linear bushings and the bottom side of the turntable |
| turntable fixture top.dwg    | attachment for the top side of the turntable                                     |
| motor attachment.dwg         | the topmost layer used to attach the jointed arm                                 |

