String mapEquipmentSlotToPanelSlot(String slot, String type, String name) {
  // First check the type field
  if (type.toLowerCase().contains('gauntlet') &&
      !type.toLowerCase().contains('armor')) {
    return 'Hands';
  } else if (type.toLowerCase().contains('belt')) {
    return 'Belt';
  } else if (type.toLowerCase().contains('weapon')) {
    return 'Weapon';
  } else if (type.toLowerCase().contains('shield') ||
      type.toLowerCase().contains('manual')) {
    return 'Offhand';
  } else if (type.toLowerCase().contains('charm') ||
      type.toLowerCase().contains('accessory')) {
    return 'Accessory 1';
  } else if (type.toLowerCase().contains('head') ||
      type.toLowerCase().contains('helm') ||
      type.toLowerCase().contains('hat')) {
    return 'Head';
  } else if (type.toLowerCase().contains('chest') ||
      type.toLowerCase().contains('armor') ||
      type.toLowerCase().contains('robe')) {
    return 'Chest';
  } else if (type.toLowerCase().contains('pants') ||
      type.toLowerCase().contains('leggings')) {
    return 'Pants';
  } else if (type.toLowerCase().contains('shoes') ||
      type.toLowerCase().contains('boots')) {
    return 'Shoes';
  }

  // Then check the name field
  if (name.toLowerCase().contains('gauntlet') &&
      !name.toLowerCase().contains('armor')) {
    return 'Hands';
  } else if (name.toLowerCase().contains('belt')) {
    return 'Belt';
  } else if (name.toLowerCase().contains('axe') ||
      name.toLowerCase().contains('sword') ||
      name.toLowerCase().contains('weapon') ||
      name.toLowerCase().contains('blade') ||
      name.toLowerCase().contains('staff')) {
    return 'Weapon';
  } else if (name.toLowerCase().contains('shield') ||
      name.toLowerCase().contains('manual')) {
    return 'Offhand';
  } else if (name.toLowerCase().contains('charm') ||
      name.toLowerCase().contains('accessory') ||
      name.toLowerCase().contains('ring') ||
      name.toLowerCase().contains('amulet')) {
    return 'Accessory 1';
  } else if (name.toLowerCase().contains('head') ||
      name.toLowerCase().contains('helm') ||
      name.toLowerCase().contains('hat') ||
      name.toLowerCase().contains('crown') ||
      name.toLowerCase().contains('hood')) {
    return 'Head';
  } else if (name.toLowerCase().contains('chest') ||
      name.toLowerCase().contains('armor') ||
      name.toLowerCase().contains('robe') ||
      name.toLowerCase().contains('cloak')) {
    return 'Chest';
  } else if (name.toLowerCase().contains('pants') ||
      name.toLowerCase().contains('leggings')) {
    return 'Pants';
  } else if (name.toLowerCase().contains('shoes') ||
      name.toLowerCase().contains('boots')) {
    return 'Shoes';
  }

  // If no match found, return the original slot
  return slot;
}
