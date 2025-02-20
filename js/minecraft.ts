let offset = pos(10, 0, 10)
let playerPosition: Position;

let stoneBlocks: Block[] = [STONE, STONE_BRICKS, COBBLESTONE, CRACKED_STONE_BRICKS, MOSSY_STONE_BRICKS]

player.onChat("pos", () => {
    player.say(player.position())
})

player.onChat("castle", () => {
    playerPosition = player.position().add(offset)
    castle()
})

let castle = () => {
    let size = 41
    let buffer = 8
    let height = 10
    let radius = 4
    let thickness = 5
    let gateCentre = world((size - 1) / 2, 0, 0)
    let gateSize = 7
    

    buildThickWall(world(0, 0, 0), world(size, 0, 0), height, thickness)

    buildGate(gateCentre, gateSize, thickness + 2)

    buildGround(size, buffer, GRASS)

    buildThickWall(world(0, 0, 0), world(0, 0, size), height, thickness)
    buildThickWall(world(size, 0, 0), world(size, 0, size), height, thickness)
    buildThickWall(world(0, 0, size), world(size, 0, size), height, thickness)

    buildTower(world(0, 0, 0), radius, height + 3)
    buildTower(world(0, 0, size), radius, height + 3)
    buildTower(world(size, 0, 0), radius, height + 3)
    buildTower(world(size, 0, size), radius, height + 3)

    
}

let buildGate = (centre: Position, size: number, thickness: number) => {
    let shift = Math.floor((thickness + 1) / 2)
    centre = centre.add(world(0, 0, -shift)).add(playerPosition)
    for (let i = 0; i < thickness; i++) {
        centre = centre.add(world(0, 0, 1))
        shapes.circle(COBBLESTONE, centre, size, Axis.Z, ShapeOperation.Hollow)
    }
}

let buildThickWall = (pos1: Position, pos2: Position, height: number, thickness: number) => {
    let shift = Math.floor((thickness - 1) / 2); // Centering adjustment

    if (pos1.getValue(Axis.Z) === pos2.getValue(Axis.Z)) {
        // Wall is along the X-axis, thickness expands along Z
        let start = pos1.add(world(0, 0, -shift));
        let end = pos2.add(world(0, 0, -shift));

        for (let i = 0; i < thickness; i++) {
            if (i === 0 || i === thickness - 1) {
                buildWall(start, end, height);
            } else {
                drawLine(start.add(playerPosition),
                    end.add(playerPosition),
                    world(0, height - 2, 0).add(playerPosition).getValue(Axis.Y),
                    place);   
            }
            start = start.add(world(0, 0, 1));
            end = end.add(world(0, 0, 1));
        }
    } else if (pos1.getValue(Axis.X) === pos2.getValue(Axis.X)) {
        // Wall is along the Z-axis, thickness expands along X
        let start = pos1.add(world(-shift, 0, 0));
        let end = pos2.add(world(-shift, 0, 0));

        for (let i = 0; i < thickness; i++) {
            if (i === 0 || i === thickness - 1) {
                buildWall(start, end, height);
            } else {
                drawLine(start.add(playerPosition), 
                         end.add(playerPosition), 
                         world(0, height - 2, 0).add(playerPosition).getValue(Axis.Y),
                         place);
            }
            start = start.add(world(1, 0, 0));
            end = end.add(world(1, 0, 0));
        }
    }
};


let buildTower = (center: Position, radius: number, height: number) => {
    center = center.add(playerPosition)
    for (let i = 0; i < height; i++) {        
        drawCircle(center.add(world(0, i, 0)), radius, place)
    }
    let size = (radius * 2 - 2);
    let groundPos = center.add(world((-size/2), height - 1, (-size/2)));
    for (let i = 0; i < size; i++) {
        buildGround2(groundPos, size, STONE_BRICKS)
    }
}

let buildGround2 = (pos: Position, size: number, block: Block, buffer = 0) => {
    for (let x = -buffer; x <= size + buffer; x++) {
        shapes.line(block, world(x, -1, -buffer).add(pos), world(x, -1, size + buffer).add(pos))
    }
}

let buildGround = (size: number, buffer: number, block: Block) => {
    for (let x = -buffer; x <= size + buffer; x++) {
        shapes.line(block, world(x , -1, -buffer).add(playerPosition), world(x, -1, size + buffer).add(playerPosition))
    }
}

let place = (x: number, y: number, z: number) => {
    let block = stoneBlocks[Math.floor(Math.random() * stoneBlocks.length)];
    blocks.place(block, world(x, y, z))
}

let buildWall = (pos1: Position, pos2: Position, height: number) => {
    for (let i = 0; i < height; i++) {
        let heightAsPos = world(0, i, 0).add(playerPosition)

        drawLine(heightAsPos.add(pos1), 
                 heightAsPos.add(pos2),
                 heightAsPos.getValue(Axis.Y),
                 place)
    }
}

let drawLine = (pos1: Position, pos2: Position, height: number, callback: Function) => {
    
    let x1 = pos1.getValue(Axis.X)
    let z1 = pos1.getValue(Axis.Z)
    let x2 = pos2.getValue(Axis.X)
    let z2 = pos2.getValue(Axis.Z)
    
    let dx = Math.abs(x2 - x1);
    let dy = Math.abs(z2 - z1);
    let sx = x1 < x2 ? 1 : -1;
    let sy = z1 < z2 ? 1 : -1;
    let err = dx - dy;

    while (true) {
        callback(x1, height, z1);

        if (x1 === x2 && z1 === z2) break;
        let e2 = 2 * err;
        if (e2 > -dy) {
            err -= dy;
            x1 += sx;
        }
        if (e2 < dx) {
            err += dx;
            z1 += sy;
        }
    }
}

let drawCircle = (pos: Position, radius: number, callback: Function) => {

    let cx = pos.getValue(Axis.X);
    let cy = pos.getValue(Axis.Z);
    let height = pos.getValue(Axis.Y);
    let x = radius, y = 0;
    let p = 1 - radius; 

    while (x >= y) {
        callback(cx + x, height, cy + y);
        callback(cx - x, height, cy + y);
        callback(cx + x, height, cy - y);
        callback(cx - x, height, cy - y);
        callback(cx + y, height, cy + x);
        callback(cx - y, height, cy + x);
        callback(cx + y, height, cy - x);
        callback(cx - y, height, cy - x);

        y++;

        if (p <= 0) {
            p += 2 * y + 1;
        } else {
            x--;
            p += 2 * (y - x) + 1;
        }
    }
}