String mapEquipmentSlotToPanelSlot(String slot, String type, String name) {
  // First check the type field
  if (type.toLowerCase().contains('gauntlet')) {
    return 'Hands';
  } else if (type.toLowerCase().contains('belt')) {
    return 'Belt';
  } else if (type.toLowerCase().contains('weapon')) {
    return 'Weapon';
  } else if (type.toLowerCase().contains('shield') ||
      type.toLowerCase().contains('manual')) {
    return 'Offhand';
  } else if (type.toLowerCase().contains('charm')) {
    return 'Accessory 1';
  }

  // Then check the name field
  if (name.toLowerCase().contains('gauntlet')) {
    return 'Hands';
  } else if (name.toLowerCase().contains('belt')) {
    return 'Belt';
  } else if (name.toLowerCase().contains('axe') ||
      name.toLowerCase().contains('sword') ||
      name.toLowerCase().contains('weapon')) {
    return 'Weapon';
  } else if (name.toLowerCase().contains('shield') ||
      name.toLowerCase().contains('manual')) {
    return 'Offhand';
  } else if (name.toLowerCase().contains('charm')) {
    return 'Accessory 1';
  }

  // If no match found, return the original slot
  return slot;
}
