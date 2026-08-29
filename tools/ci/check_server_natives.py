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

# FiveM CLIENT Lua sandbox-da os.date / os.time mövcud deyil (server-də var).
CLIENT_OS_PATTERN = re.compile(r"\bos\.(date|time)\s*\(")


def server_files():
    for base in ROOT.glob("resources/*/server"), ROOT.glob("resources/*/*/server"):
        for d in base:
            if d.is_dir():
                yield from d.rglob("*.lua")


def client_files():
    for base in ROOT.glob("resources/*/client"), ROOT.glob("resources/*/*/client"), \
                    ROOT.glob("resources/*/shared"), ROOT.glob("resources/*/*/shared"):
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
    for f in sorted(client_files()):
        text = f.read_text(encoding="utf-8", errors="replace")
        for lineno, line in enumerate(text.splitlines(), 1):
            stripped = line.strip()
            if stripped.startswith("--"):
                continue
            m = CLIENT_OS_PATTERN.search(line)
            if m:
                problems += 1
                rel = f.relative_to(ROOT)
                print(f"  ❌ {rel}:{lineno} client-də os.{m.group(1)} yoxdur (GetPosixTime işlədin)")
    if problems:
        print(f"\n{problems} problem tapıldı.")
        print("Entity yaratmaq üçün resources/[core]/196rp_spawner istifadə edin.")
        return 1
    print("Server fayllarında client-only native yoxdur; client-də os.* yoxdur.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
