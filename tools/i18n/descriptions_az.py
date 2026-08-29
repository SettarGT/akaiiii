#!/usr/bin/env python3
"""qb-core/shared/items.lua — qalan ingiliscə description-ların Azərbaycana tərcüməsi."""
import re
import pathlib

AZ_DESC = {
    "A .50 caliber firearm designed to be held with both hands": "İki əllə tutulan .50 kalibrli atəş silahı",
    "A ball of packed snow, especially one made for throwing at other people for fun": "Sıxılmış qar topu — adətən əyləncə üçün başqalarına atılır",
    "A barrel for a weapon": "Silah üçün lülə",
    "A battery-operated portable light": "Batareya ilə işləyən portativ işıq",
    "A bomb placed on the ground that detonates when going within its proximity": "Yaxınlaşdıqda partlayan yerə qoyulmuş bomba",
    "A bomb that produces a lot of smoke when it explodes": "Partlayanda çoxlu tüstü yaradan bomba",
    "A boom camo for a weapon": "Silah üçün boom kamuflyajı",
    "A briefcase for storing important documents": "Vacib sənədləri saxlamaq üçün portfel",
    "A broad, heavy knife used as a weapon": "Silah kimi istifadə edilən geniş, ağır bıçaq",
    "A broken bottle": "Sınıq butulka",
    "A brushstroke camo for a weapon": "Silah üçün fırça vuruşu kamuflyajı",
    "A cannister of gas that causes extreme pain": "Şiddətli ağrı yaradan qaz balonu",
    "A clip for a weapon": "Silah üçün daraq",
    "A club used to hit the ball in golf": "Qolfda topu vurmaq üçün istifadə edilən çubuq",
    "A combat version of a handheld light weight machine gun": "Əl pulemyotunun döyüş versiyası",
    "A combat version of an automatic gun that fires bullets in rapid succession for as long as the trigger is pressed": "Tətiyə basıldığı müddətcə ardıcıl atəş edən avtomatik silahın döyüş versiyası",
    "A combat version small firearm designed to be held in one hand": "Bir əllə tutulan kiçik atəş silahının döyüş versiyası",
    "A compact automatic assault rifle": "Kompakt avtomatik hücum tüfəngi",
    "A compact grenade launcher": "Kompakt qumbaraatan",
    "A compact smoothbore gun for firing small shot at short range": "Qısa məsafədə kiçik güllə atan kompakt hamar lüləli silah",
    "A compact version of an assault rifle": "Hücum tüfənginin kompakt versiyası",
    "A compensator for a weapon": "Silah üçün kompensator",
    "A crude bomb made of a bottle filled with a flammable liquid and fitted with a wick for lighting": "Yanğına davamlı maye ilə doldurulmuş və fitilli sərt bomba",
    "A device containing gunpowder and other combustible chemicals that causes a spectacular explosion when ignited": "Barıt və digər yanar kimyəvi maddələr ehtiva edən, alovlandıqda möhtəşəm partlayış yaradan cihaz",
    "A digital camo for a weapon": "Silah üçün rəqəmsal kamuflyaj",
    "A drum for a weapon": "Silah üçün baraban",
    "A flashlight for a weapon": "Silah üçün fənər",
    "A garbage bag": "Zibil kisəsi",
    "A geometric camo for a weapon": "Silah üçün həndəsi kamuflyaj",
    "A grip for a weapon": "Silah üçün qulp",
    "A handgun for firing signal rockets": "Siqnal raketləri atmaq üçün tapança",
    "A handheld light weight machine gun": "Əl pulemyotu",
    "A handheld throwable bomb": "Əllə atılan bomba",
    "A hefty firearm designed to be held in one hand (or attempted)": "Bir əllə tutulmaq üçün nəzərdə tutulmuş ağır atəş silahı (və ya cəhd)",
    "A high-precision, long-range rifle": "Yüksək dəqiqlikli, uzun mənzilli tüfəng",
    "A holo scope for a weapon": "Silah üçün holoskoop nişangah",
    "A homemade bomb, the components of which are contained in a pipe": "Komponentləri boruda yerləşən ev istehsalı bomba",
    "A knife with a blade that springs out from the handle when a button is pressed": "Düymə basıldıqda qınından çıxan bıçaq",
    "A large broad-bladed axe used in ancient warfare": "Qədim döyüşlərdə istifadə edilən böyük enli balta",
    "A large scope for a weapon": "Silah üçün böyük nişangah",
    "A large smoothbore gun for firing small shot at short range": "Qısa məsafədə kiçik güllə atan böyük hamar lüləli silah",
    "A leopard camo for a weapon": "Silah üçün bəbir kamuflyajı",
    "A light weight automatic rifle": "Yüngül avtomatik tüfəng",
    "A luxury finish for a weapon": "Silah üçün lüks bitirmə",
    "A medium scope for a weapon": "Silah üçün orta nişangah",
    "A metal guard worn over the knuckles in fighting, especially to increase the effect of the blows": "Döyüşdə barmaq oynaqlarının üstünə geyilən metal qoruyucu — zərbələrin effektini artırır",
    "A mini handheld light weight machine gun": "Mini əl pulemyotu",
    "A muzzle brake for a weapon": "Silah üçün ağız əyləci",
    "A muzzle brakee for a weapon": "Silah üçün ağız əyləci",
    "A night vision scope for a weapon": "Silah üçün gecə görüşü nişangahı",
    "A pair of lockable linked metal rings for securing a prisoner's wrists": "Məhbusun biləklərini bağlamaq üçün kilidlənən metal halqalar",
    "A patriot camo for a weapon": "Silah üçün patriot kamuflyajı",
    "A perseus camo for a weapon": "Silah üçün perseus kamuflyajı",
    "A pistol with revolving chambers enabling several shots to be fired without reloading": "Yenidən doldurmadan bir neçə atəş etməyə imkan verən fırlanan kameralı tapança",
    "A police officer's club or billy": "Polis əməkdaşının dəyənəyi",
    "A portable device that discharges a jet of water, foam, gas, or other material to extinguish a fire": "Yanğını söndürmək üçün su, köpük, qaz və ya digər material axını buraxan portativ cihaz",
    "A portable high-precision, long-range rifle": "Portativ yüksək dəqiqlikli, uzun mənzilli tüfəng",
    "A portable machine gun consisting of a rotating cluster of six barrels and capable of variable rates of fire of up to 6,000 rounds per minute": "Altı lülədən ibarət fırlanan dəstə malik, dəqiqədə 6000 atəşə qədər çıxa bilən portativ pulemyot",
    "A pump-action smoothbore gun for firing small shot at short range": "Qısa məsafədə kiçik güllə atan nasos mexanizmlə işləyən hamar lüləli silah",
    "A rapid-fire, magazine-fed automatic rifle designed for infantry use": "Piyada istifadəsi üçün nəzərdə tutulmuş sürətli atəşli, jurnal ilə işləyən avtomatik tüfəng",
    "A robust liquid container made from pressed steel": "Preslənmiş poladdan hazırlanmış möhkəm maye qabı",
    "A rocket-propelled grenade launcher": "Raketlə hərəkətə gələn qumbaraatan",
    "A sawn-off smoothbore gun for firing small shot at short range": "Qısa məsafədə kiçik güllə atan kəsilmiş hamar lüləli silah",
    "A self-loading pistol capable of burst or fully automatic fire": "Seriya və ya tam avtomatik atəşə qadir özünü dolduran tapança",
    "A sessanta nove camo for a weapon": "Silah üçün sessanta nove kamuflyajı",
    "A short knife with a pointed and edged blade, used as a weapon": "Silah kimi istifadə olunan iti uclu qısa bıçaq",
    "A shotgun capable of rapid continous fire": "Sürətli davamlı atəşə qadir ov tüfəngi",
    "A shotgun with two parallel barrels, allowing two single shots to be fired in quick succession": "İki paralel lüləli ov tüfəngi — iki tək atəşi ardıcıl atmağa imkan verir",
    "A skull camo for a weapon": "Silah üçün kəllə kamuflyajı",
    "A small axe with a short handle for use in one hand": "Bir əllə istifadə üçün qısa dəstəkli kiçik balta",
    "A small firearm designed to be held in one hand": "Bir əllə tutulmaq üçün nəzərdə tutulmuş kiçik atəş silahı",
    "A small firearm designed to be held in one hand that is automatic": "Bir əllə tutulan avtomatik kiçik atəş silahı",
    "A small pyrotechnic devices used for illumination and signalling": "İşıqlandırma və siqnal üçün istifadə edilən kiçik pirotexniki cihazlar",
    "A small scope for a weapon": "Silah üçün kiçik nişangah",
    "A solid or hollow spherical or egg-shaped object that is kicked, thrown, or hit in a game": "Oyunda təpiklənən, atılan və ya vurulan bərk və ya içi boş kürə və ya yumurta formalı obyekt",
    "A stick used to strike a ball, usually the cue ball (or other things)": "Topu vurmaq üçün istifadə edilən çubuq (adətən bilyard topu)",
    "A suppressor for a weapon": "Silah üçün səssizləşdirici",
    "A thermal scope for a weapon": "Silah üçün termal nişangah",
    "A tool used for gripping and turning nuts, bolts, pipes, etc": "Qaykaları, boltları, boruları tutmaq və fırlatmaq üçün alət",
    "A very accurate single-fire rifle": "Çox dəqiq tək atəşli tüfəng",
    "A very accurate small firearm designed to be held in one hand": "Bir əllə tutulan çox dəqiq kiçik atəş silahı",
    "A very small firearm designed to be easily concealed": "Asanlıqla gizlədilə bilən çox kiçik atəş silahı",
    "A weapon firing barbs attached by wires to batteries, causing temporary paralysis": "Müvəqqəti iflic yaradan, naqillərlə batareyalara bağlanmış iynələr atan silah",
    "A weapon fitted with an electronic device that enables it to find and hit a target": "Hədəfi tapmağa və vurmağa imkan verən elektron cihazla təchiz edilmiş silah",
    "A weapon that fires a specially-designed large-caliber projectile, often with an explosive, smoke or gas warhead": "Çox vaxt partlayıcı, tüstü və ya qaz döyüş başlığı olan xüsusi dizaynlı böyük kalibrli mərmi atan silah",
    "A weapon that uses electromagnetic force to launch high velocity projectiles": "Yüksək sürətli mərmiləri elektromaqnit qüvvəsi ilə atan silah",
    "A woodland camo for a weapon": "Silah üçün meşə kamuflyajı",
    "A zebra camo for a weapon": "Silah üçün zebra kamuflyajı",
    "Ammo for EMP Launcher": "EMP Qumbaraatan üçün daraq",
    "Ammo for Machine Guns": "Pulemyotlar üçün daraq",
    "Ammo for Pistols": "Tapançalar üçün daraq",
    "Ammo for Rifles": "Tüfənglər üçün daraq",
    "Ammo for Shotguns": "Ov tüfəngləri üçün daraq",
    "Ammo for Sniper Rifles": "Snayper tüfəngləri üçün daraq",
    "Ammo for Sub Machine Guns": "Avtomat tapançalar üçün daraq",
    "An advanced scope for a weapon": "Silah üçün qabaqcıl nişangah",
    "An antique firearm designed to be held in one hand": "Bir əllə tutulmaq üçün nəzərdə tutulmuş antik atəş silahı",
    "An assault version of a handheld light weight machine gun": "Əl pulemyotunun hücum versiyası",
    "An assault version of a rapid-fire, magazine-fed automatic rifle designed for infantry use": "Piyada istifadəsi üçün nəzərdə tutulmuş sürətli atəşli avtomatik tüfəngin hücum versiyası",
    "An assault version of asmoothbore gun for firing small shot at short range": "Qısa məsafədə kiçik güllə atan hamar lüləli silahın hücum versiyası",
    "An automatic gun that fires bullets in rapid succession for as long as the trigger is pressed": "Tətiyə basıldığı müddətcə ardıcıl atəş edən avtomatik silah",
    "An automatic rifle commonly referred to as a tommy gun": "Adətən tommy gun adlandırılan avtomatik tüfəng",
    "An explosive charge covered with an adhesive that when thrown against an object sticks until it explodes": "Obyektə atıldıqda partlayana qədər yapışan yapışqan örtüklü partlayıcı yük",
    "An explosive charge that can be remotely detonated": "Uzaqdan partladıla bilən partlayıcı yük",
    "An extremely versatile assault rifle for any combat situation": "İstənilən döyüş vəziyyəti üçün son dərəcə çoxfunksiyalı hücum tüfəngi",
    "An infantryman's primary rifle": "Piyada əsgərinin əsas tüfəngi",
    "An instrument composed of a blade fixed into a handle, used for cutting or as a weapon": "Kəsmək və ya silah kimi istifadə edilən, dəstəyə bərkidilmiş bıçaqdan ibarət alət",
    "An iron bar with a flattened end, used as a lever": "Lever kimi istifadə edilən, ucu yastı dəmir çubuq",
    "An upgraded high-precision, long-range rifle": "Təkmilləşdirilmiş yüksək dəqiqlikli, uzun mənzilli tüfəng",
    "An upgraded small firearm designed to be held in one hand": "Bir əllə tutulmaq üçün təkmilləşdirilmiş kiçik atəş silahı",
    "Army Weapon Tint": "Ordu silah rəngi",
    "Assault Rifle MK2": "Hücum Tüfəngi MK2",
    "Blue Contrast Weapon Tint for MK2 Weapons": "MK2 silahlar üçün mavi kontrast rəng",
    "Bold Blue & White Weapon Tint for MK2 Weapons": "MK2 silahlar üçün tünd mavi və ağ rəng",
    "Bold Cyan Features Weapon Tint for MK2 Weapons": "MK2 silahlar üçün tünd firuzəyi rəng",
    "Bold Green & Purple Weapon Tint for MK2 Weapons": "MK2 silahlar üçün tünd yaşıl və bənövşəyi rəng",
    "Bold Green Features Weapon Tint for MK2 Weapons": "MK2 silahlar üçün tünd yaşıl rəng",
    "Bold Orange Weapon Tint for MK2 Weapons": "MK2 silahlar üçün tünd narıncı rəng",
    "Bold Pink Weapon Tint for MK2 Weapons": "MK2 silahlar üçün tünd çəhrayı rəng",
    "Bold Purple & Yellow Weapon Tint for MK2 Weapons": "MK2 silahlar üçün tünd bənövşəyi və sarı rəng",
    "Bold Red & White Weapon Tint for MK2 Weapons": "MK2 silahlar üçün tünd qırmızı və ağ rəng",
    "Bold Red Features Weapon Tint for MK2 Weapons": "MK2 silahlar üçün tünd qırmızı rəng",
    "Bold Yellow Features Weapon Tint for MK2 Weapons": "MK2 silahlar üçün tünd sarı rəng",
    "Bread...?": "Çörək...?",
    "Bull Puprifle MK2": "Bull tüfəngi MK2",
    "Candy Cane": "Şirniyyat çubuğu",
    "Carbine Rifle MK2": "Karbin Tüfəngi MK2",
    "Classic Beige Weapon Tint for MK2 Weapons": "MK2 silahlar üçün klassik bej rəng",
    "Classic Black Weapon Tint for MK2 Weapons": "MK2 silahlar üçün klassik qara rəng",
    "Classic Blue Weapon Tint for MK2 Weapons": "MK2 silahlar üçün klassik mavi rəng",
    "Classic Brown & Black Weapon Tint for MK2 Weapons": "MK2 silahlar üçün klassik qəhvəyi və qara rəng",
    "Classic Earth Weapon Tint for MK2 Weapons": "MK2 silahlar üçün klassik torpaq rəngi",
    "Classic Gray Weapon Tint for MK2 Weapons": "MK2 silahlar üçün klassik boz rəng",
    "Classic Green Weapon Tint for MK2 Weapons": "MK2 silahlar üçün klassik yaşıl rəng",
    "Classic Two-Tone Weapon Tint for MK2 Weapons": "MK2 silahlar üçün klassik iki rəngli rəng",
    "Classic White Weapon Tint for MK2 Weapons": "MK2 silahlar üçün klassik ağ rəng",
    "Comes in handy when people misbehave. Maybe it can be used for something else?": "İnsanlar pis davrandıqda işə yarar. Bəlkə başqa bir şey üçün də istifadə oluna bilər?",
    "Default/Black Weapon Tint": "Standart/Qara silah rəngi",
    "Double Action Revolver": "İkiqat Təsirli Revolver",
    "Fisticuffs": "Yumruqlar",
    "Gold Weapon Tint": "Qızılı silah rəngi",
    "Green Weapon Tint": "Yaşıl silah rəngi",
    "LSPD Weapon Tint": "LSPD silah rəngi",
    "Metallic Blue Weapon Tint for MK2 Weapons": "MK2 silahlar üçün metalik mavi rəng",
    "Metallic Gold Weapon Tint for MK2 Weapons": "MK2 silahlar üçün metalik qızılı rəng",
    "Metallic Gray & Lilac Weapon Tint for MK2 Weapons": "MK2 silahlar üçün metalik boz və yasəmən rəngi",
    "Metallic Green Weapon Tint for MK2 Weapons": "MK2 silahlar üçün metalik yaşıl rəng",
    "Metallic Orange & Yellow Weapon Tint for MK2 Weapons": "MK2 silahlar üçün metalik narıncı və sarı rəng",
    "Metallic Platinum Weapon Tint for MK2 Weapons": "MK2 silahlar üçün metalik platin rəng",
    "Metallic Purple & Lime Weapon Tint for MK2 Weapons": "MK2 silahlar üçün metalik bənövşəyi və əhəng rəngi",
    "Metallic Red Weapon Tint for MK2 Weapons": "MK2 silahlar üçün metalik qırmızı rəng",
    "Metallic Red and Yellow Weapon Tint for MK2 Weapons": "MK2 silahlar üçün metalik qırmızı və sarı rəng",
    "Metallic White & Aqua Weapon Tint for MK2 Weapons": "MK2 silahlar üçün metalik ağ və akvamarin rəng",
    "Orange Contrast Weapon Tint for MK2 Weapons": "MK2 silahlar üçün narıncı kontrast rəng",
    "Orange Weapon Tint": "Narıncı silah rəngi",
    "Pink Weapon Tint": "Çəhrayı silah rəngi",
    "Pistol XM3": "Tapança XM3",
    "Platinum Weapon Tint": "Platin silah rəngi",
    "Pumpshotgun MK2": "Nasoslu Ov Tüfəngi MK2",
    "Red Contrast Weapon Tint for MK2 Weapons": "MK2 silahlar üçün qırmızı kontrast rəng",
    "SMG MK2": "Avtomat Tapança MK2",
    "SNS Pistol MK2": "SNS Tapança MK2",
    "Stone Hatchet": "Daş baltası",
    "Used for hitting a ball in sports (or other things)": "İdmanda topu vurmaq üçün istifadə olunur (və ya digər şeylər üçün)",
    "Used for jobs such as breaking things (legs) and driving in nails": "Bir şeyləri (ayaqları) sındırmaq və mıx çalmaq kimi işlər üçün istifadə olunur",
    "Weapon Ceramicpistol": "Keramik Tapança",
    "Weapon Combatmg MK2": "Döyüş Pulemyotu MK2",
    "Weapon Combatshotgun": "Döyüş Ov Tüfəngi",
    "Weapon Gadgetpistol": "Qadjet Tapança",
    "Weapon Hazardcan": "Təhlükəli Qaz Balonu",
    "Weapon Heavysniper MK2": "Ağır Snayper MK2",
    "Weapon Marksmanrifle MK2": "Marksmen Tüfəngi MK2",
    "Weapon Militaryrifle": "Hərbi Tüfəng",
    "Weapon Navyrevolver": "Hərbi Dəniz Revolveri",
    "Weapon Raycarbine": "Şüa Karbini",
    "Weapon Rayminigun": "Şüa Pulemyotu",
    "Weapon Raypistol": "Şüa Tapançası",
    "Weapon Wpecialcarbine MK2": "Xüsusi Karbin MK2",
    "Wonderfull for nice vacation to Liberty City": "Liberty City-yə gözəl tətil üçün əla",
    "Yellow Contrast Weapon Tint for MK2 Weapons": "MK2 silahlar üçün sarı kontrast rəng",
    "da Violence": "Zorakılıq",
}

LUA_MAP = {
    "\\'": "'", "\\\\": "\\", '\\"': '"', "\\n": "\n",
}


def unescape(s: str) -> str:
    out, i = [], 0
    while i < len(s):
        if s[i] == "\\" and i + 1 < len(s):
            two = s[i:i+2]
            if two in LUA_MAP:
                out.append(LUA_MAP[two]); i += 2; continue
            out.append(s[i]); i += 1; continue
        out.append(s[i]); i += 1
    return "".join(out)


def escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'")


def main():
    p = pathlib.Path("resources/[qb]/qb-core/shared/items.lua")
    text = p.read_text(encoding="utf-8")

    def repl(m):
        dec = unescape(m.group(1))
        if dec in AZ_DESC:
            return "description = '" + escape(AZ_DESC[dec]) + "'"
        return m.group(0)

    pat = re.compile(r"description\s*=\s*'((?:[^'\\]|\\.)*)'")
    text, n = pat.subn(repl, text)
    p.write_text(text, encoding="utf-8")
    print("replaced:", n)


if __name__ == "__main__":
    main()
