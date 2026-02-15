# PandaCSS Patterns

Quick reference for PandaCSS-specific conventions. Each pattern shows incorrect → correct usage.

## boxSize for equal dimensions

```diff
- width: '24px', height: '24px'
+ boxSize: '24px'
```

## Logical properties

```diff
- top: '10px', right: '10px', paddingLeft: '12px'
+ insetBlockStart: '10px', insetInlineEnd: '10px', paddingInlineStart: '12px'
```

## data-palette + colorPalette for dynamic colors

```diff
- css={{ backgroundColor: palette === 'red' ? 'red.500' : 'blue.500' }}
+ data-palette={palette} css={{ backgroundColor: 'colorPalette.main' }}
```

## token() for inline styles

```diff
- style={{ boxShadow: 'var(--shadows-canvas)' }}
+ style={{ boxShadow: token('shadows.canvas') }}
```

## _childIcon for icon styling

Size and color icons via CSS, not props:

```diff
- <ChevronIcon size={16} color="gray.500" />
+ <styled.span css={{ _childIcon: { boxSize: '4', color: 'gray.500' } }}><ChevronIcon /></styled.span>
```

## Data attributes for conditional styles

```diff
- css={{ color: isActive ? 'blue' : 'gray' }}
+ data-palette={isActive} css={{ color: 'gray', _active: { color: 'blue' } }}
```

## General

- **Use existing tokens** — check if a token exists before using escape hatches.
