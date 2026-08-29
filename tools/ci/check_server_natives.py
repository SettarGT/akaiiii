#!/usr/bin/env python3
"""Server Lua fayllarinda client-only native-lərin işlədilməsini yoxlayır.

FiveM-də SERVER entity YARADA və vizual/task native-ləri işlədə BİLMƏZ
(CreateVehicle, RequestModel, SetVehicleDoorsLocked, TaskWarpPedIntoVehicle və s.).
Bu native-lər server tərəfdə `nil` olur və runtime SCRIPT ERROR yaradır.
Server yalnız bunları bilər: DoesEntityExist, DeleteEntity, GetEntityCoords,
GetEntityHeading, GetPlayerPed, NetworkGet*/..., CreateVehicleServerSetter,
SetEntityOrphanMode, SetEntityRoutingBucket və s.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

FORBIDDEN = [
    "RequestModel", "HasModelLoaded", "SetModelAsNoLongerNeeded",
    "CreateVehicle", "CreatePed", "CreatePedInsideVehicle", "CreateObject",
    "SetEntityAsMissionEntity", "SetEntityInvincible", "SetEntityHeading",
    "FreezeEntityPosition",
    "SetVehicleDoorsLocked", "SetVehicleDoorsLockedForAllPlayers",
    "SetVehicleEngineOn", "SetVehicleOnGroundProperly",
    "SetVehicleNumberPlateText", "SetVehicleCustomPrimaryColour",
    "SetVehicleCustomSecondaryColour", "SetVehicleColours", "SetVehicleExtraColours",
    "SetVehicleHasBeenOwnedByPlayer", "SetVehicleCanBeUsedByFleeingPeds",
    "SetVehicleRadioEnabled",
    "SetPedKeepTask", "SetBlockingOfNonTemporaryEvents", "SetPedCanBeDraggedOut",
    "SetPedCanRagdoll", "SetDriverAbility", "SetDriverAggressiveness",
    "SetPedIntoVehicle", "TaskWarpPedIntoVehicle",
    "TaskVehicleDriveToCoordLongrange",
    "GetClockHours",
]

PATTERN = re.compile(r"\b(" + "|".join(FORBIDDEN) + r")\s*\(")


def server_files():
    for base in ROOT.glob("resources/*/server"), ROOT.glob("resources/*/*/server"):
        for d in base:
            if d.is_dir():
                yield from d.rglob("*.lua")


def main():
    problems = 0
    for f in sorted(server_files()):
        text = f.read_text(encoding="utf-8", errors="replace")
        for lineno, line in enumerate(text.splitlines(), 1):
            stripped = line.strip()
            if stripped.startswith("--"):
                continue
            m = PATTERN.search(line)
            if m:
                problems += 1
                rel = f.relative_to(ROOT)
                print(f"  ❌ {rel}:{lineno} client-only native: {m.group(1)}")
    if problems:
        print(f"\n{problems} server faylında client-only native tapıldı.")
        print("Entity yaratmaq üçün resources/[core]/196rp_spawner istifadə edin.")
        return 1
    print("Server fayllarında client-only native yoxdur.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
