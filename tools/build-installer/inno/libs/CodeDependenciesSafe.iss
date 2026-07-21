[Code]
// CnCNet additions on top of InnoDependencyInstaller.
//
// Based on: https://github.com/DomGries/InnoDependencyInstaller
// File:     CodeDependencies.iss
// Commit:   8b01d3e1a039596cdb8c035992d826ce9639e31f (the submodule pin of
//           libs/InnoDependencyInstaller; keep this file in sync when the
//           submodule is updated)
//
// Dependency_AddVCRedistsSafe mirrors upstream's Dependency_AddVC2005 through
// Dependency_AddVC2022 with identical GUIDs, minimum versions, URLs and
// installer parameters. The only functional change is that the Windows
// Installer query goes through Dependency_IsMsiProductInstalledSafe: the Inno
// Setup built-in IsMsiProductInstalled raises an exception when Windows
// Installer itself is broken (corrupted MSI configuration data, antivirus
// blocking msi.dll), which crashed the installer with
// "Runtime error (at N:328)" before any UI appeared.
//
// If upstream changes a GUID/version/URL, update the matching block below.
// Stale data fails soft: the check returns False, the redist is offered, and
// the redist installer itself no-ops when a newer version is already present.

// Wraps the Inno Setup built-in IsMsiProductInstalled (not an
// InnoDependencyInstaller function).
function Dependency_IsMsiProductInstalledSafe(const UpgradeCode: String; const PackedMinVersion: Int64): Boolean;
begin
  try
    Result := IsMsiProductInstalled(UpgradeCode, PackedMinVersion);
  except
    Log('Unable to query MSI product ' + UpgradeCode + ': ' + GetExceptionMessage);
    // Assume missing so the dependency is still offered; the redist
    // installers are idempotent, so a redundant attempt is harmless.
    Result := False;
  end;
end;

procedure Dependency_AddVCIfMissing(
  const FilenamePrefix, Parameters, Title, UpgradeCodeX86, UpgradeCodeX64: String;
  const PackedMinVersion: Int64;
  const UrlX86, UrlX64: String);
begin
  if not Dependency_IsMsiProductInstalledSafe(Dependency_String(UpgradeCodeX86, UpgradeCodeX64), PackedMinVersion) then begin
    Dependency_Add(FilenamePrefix + Dependency_ArchSuffix + '.exe',
      Parameters,
      Title + Dependency_ArchTitle,
      Dependency_String(UrlX86, UrlX64),
      '', False, False);
  end;
end;

procedure Dependency_AddVCRedistsSafe();
begin
  // mirrors Dependency_AddVC2005 (CodeDependencies.iss)
  Dependency_AddVCIfMissing('vcredist2005', '/q',
    'Visual C++ 2005 Service Pack 1 Redistributable',
    '{86C9D5AA-F00C-4921-B3F2-C60AF92E2844}', '{A8D19029-8E5C-4E22-8011-48070F9E796E}',
    PackVersionComponents(8, 0, 61000, 0),
    'https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE',
    'https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE');

  // mirrors Dependency_AddVC2008 (CodeDependencies.iss)
  Dependency_AddVCIfMissing('vcredist2008', '/q',
    'Visual C++ 2008 Service Pack 1 Redistributable',
    '{DE2C306F-A067-38EF-B86C-03DE4B0312F9}', '{FDA45DDF-8E17-336F-A3ED-356B7B7C688A}',
    PackVersionComponents(9, 0, 30729, 6161),
    'https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe',
    'https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe');

  // mirrors Dependency_AddVC2010 (CodeDependencies.iss)
  Dependency_AddVCIfMissing('vcredist2010', '/passive /norestart',
    'Visual C++ 2010 Service Pack 1 Redistributable',
    '{1F4F1D2A-D9DA-32CF-9909-48485DA06DD5}', '{5B75F761-BAC8-33BC-A381-464DDDD813A3}',
    PackVersionComponents(10, 0, 40219, 0),
    'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe',
    'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe');

  // mirrors Dependency_AddVC2012 (CodeDependencies.iss)
  Dependency_AddVCIfMissing('vcredist2012', '/passive /norestart',
    'Visual C++ 2012 Update 4 Redistributable',
    '{4121ED58-4BD9-3E7B-A8B5-9F8BAAE045B7}', '{EFA6AFA1-738E-3E00-8101-FD03B86B29D1}',
    PackVersionComponents(11, 0, 61030, 0),
    'https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe',
    'https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe');

  // mirrors Dependency_AddVC2013 (CodeDependencies.iss)
  Dependency_AddVCIfMissing('vcredist2013', '/passive /norestart',
    'Visual C++ 2013 Update 5 Redistributable',
    '{B59F5BF1-67C8-3802-8E59-2CE551A39FC5}', '{20400CF0-DE7C-327E-9AE4-F0F38D9085F8}',
    PackVersionComponents(12, 0, 40664, 0),
    'https://download.visualstudio.microsoft.com/download/pr/10912113/5da66ddebb0ad32ebd4b922fd82e8e25/vcredist_x86.exe',
    'https://download.visualstudio.microsoft.com/download/pr/10912041/cee5d6bca2ddbcd039da727bf4acb48a/vcredist_x64.exe');

  // mirrors Dependency_AddVC2022 (CodeDependencies.iss)
  Dependency_AddVCIfMissing('vcredist2022', '/passive /norestart',
    'Visual C++ 2015-2022 Redistributable',
    '{65E5BD06-6392-3027-8C26-853107D3CF1A}', '{36F68A90-239C-34DF-B58C-64B30153CE35}',
    PackVersionComponents(14, 42, 34433, 0),
    'https://aka.ms/vs/17/release/vc_redist.x86.exe',
    'https://aka.ms/vs/17/release/vc_redist.x64.exe');
end;
