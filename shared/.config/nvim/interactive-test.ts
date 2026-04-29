console.log('Starting debug test...');
console.log('Attach debugger in Neovim now!');
console.log('');
console.log('IN NEOVIM:');
console.log('1. Set a breakpoint on line 16 (console.log)');
console.log('2. Press "c" to continue');
console.log('3. Then open http://localhost:8888/trigger');
console.log('');
console.log('This should hit the breakpoint in Neovim.');
console.log('');

const server = Bun.serve({
  port: 8888,
  development: true,
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === '/trigger') {
      console.log('Triggering breakpoint...');
      return new Response('Triggered!');
    }
    return new Response('Not found');
  },
});

console.log(`Server running at http://localhost:${server.port}/`);
