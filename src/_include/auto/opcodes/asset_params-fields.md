| INDEX | NAME | TYPE | IN | NOTES |
| :-: | :------ | :--: | :-: | :--------- |
| 0 | AssetTotal | uint64 |      | Total number of units of this asset |
| 1 | AssetDecimals | uint64 |      | See AssetParams.Decimals |
| 2 | AssetDefaultFrozen | bool |      | Frozen by default or not |
| 3 | AssetUnitName | []byte |      | Asset unit name |
| 4 | AssetName | []byte |      | Asset name |
| 5 | AssetURL | []byte |      | URL with additional info about the asset |
| 6 | AssetMetadataHash | [32]byte |      | Arbitrary commitment |
| 7 | AssetManager | address |      | Manager address |
| 8 | AssetReserve | address |      | Reserve address |
| 9 | AssetFreeze | address |      | Freeze address |
| 10 | AssetClawback | address |      | Clawback address |
| 11 | AssetCreator | address | v5  | Creator address |

