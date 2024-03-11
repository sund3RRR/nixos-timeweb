# nixos-timeweb
Проект предоставляет образ NixOS для [timeweb cloud](https://timeweb.cloud/services/vds-vps).

## Использование
1) При создании новой виртуальной машины в секции **Образ** выберите вкладку **Мои образы**
2) Нажмите **Новый образ**, вставьте ссылку на образ из *releases* (например https://github.com/sund3RRR/nixos-timeweb/releases/download/v0.0.1/NixOS-23.11-timeweb.qcow2)
3) Выберите тип ОС **Другая** и нажмите **Загрузить**
4) После запуска машины залогиньтесь под рутом и запустите скрипт для генерации конфигов и обновления системы:
  ```bash
  setup-timeweb-nixos
  ```
## Модификация образа
Клонируйте репозиторий к себе на компьютер с операционной системой NixOS или установленным пакетным менеджером nix:
```bash
git clone https://github.com/sund3RRR/nixos-timeweb.git
```
Свою конфигурацию вы можете вставить в файл `image.nix`. Например добавить `ssh` ключ или же установить дополнительные пакеты:
#### **`image.nix`**
```nix
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: 
let
  qemu-ga-wrapped = pkgs.callPackage ./pkgs/ga-wrapped.nix { };
  setup-timeweb-nixos = pkgs.writeScriptBin "setup-timeweb-nixos" (builtins.readFile ./scripts/setup-timeweb-nixos.sh);
in 
{
...
users.users.root.openssh.authorizedKeys.keys = [
  "ssh-rsa AAAAB3Nz....6OWM= user" # content of authorized_keys file
  # note: ssh-copy-id will add user@your-machine after the public key
  # but we can remove the "@your-machine" part
];
...
environment.systemPackages = with pkgs; [
  wget vim htop inxi
  setup-timeweb-nixos # don't delete this!
];
...
```
Для изменения релиза NixOS зайдите на страницу официального репозитория [nixpkgs](https://github.com/NixOS/nixpkgs), выберите нужную ветку и коммит, скопируйте его `hash`.
Внесите изменения в `build.sh`
#### **`build.sh`**
```bash
NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs/archive/<your-commit-hash>.tar.gz \
  nix-shell -p nixos-generators --run "nixos-generate --format qcow --configuration ./image.nix -o result"
```
Соберите образ
```bash
./build.sh
```

## Road map
1) Настроить `dhcpd` в соответствии с настройками `dhclient` timeweb
2) Получше организовать генерацию конфигов системы

## Troubleshooting
- Минимальная конфигурация машины с 1Gb оперативной памяти может быть недостаточна для корректной работы NixOS по причине нехватки памяти. `nixos-rebuild switch` будет заканчиваться ошибкой/пустым output. Конфигурации с 2Gb должно хватить.
