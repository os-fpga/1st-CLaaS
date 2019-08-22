# A Personal History of this Project

![framework](img/SteveProfilePic.jpg)

My name is <a href="https://www.linkedin.com/in/steve-hoover-a44b607/" target="_ blank">Steve Hoover</a>. I am the proud founder of <a href="http://www.redwoodeda.com" target="_blank" atom_fix="_">Redwood EDA</a>. After 18 years of banging my head against the wall designing silicon for Intel using the misguided tools this industry produces, I decided it was time to focus on making better tools. There's no reason circuit design has to be an exclusive club for experts trained in the obscurities of an arcane ecosystem. Digital logic is just 1s and 0s. It can't get any simpler. The difficulty was entirely self-inflicted. So, I set out to fix things and regain my own sanity.

The first thing to fix, was the language. Verilog carries with it over 30 years of baggage, and other languages have missed the mark in various ways. So I created TL-Verilog as an incremental path to simpler and *way* better "transaction-level" design methodology. But let's not stop at language, as we've done in the past. We need web- and open-source-friendly tools. Transaction-level design needs to extend from the language into the platform, so I created the <a href="http://makerchip.com" target="_blank" atom_fix="_">Makerchip IDE</a> with the help of a few interns.

As I got more into the open-source community, and as I saw FPGAs becoming available in the cloud, I realized there was a revolution about to unfold. Why? Well, let's get some perspective. Open-source software has been going gangbusters for years, transforming the software industry time and time again. All the while, circuit design has been done using Verilog and text editors. We've been standing still. But it gets worse. Since we started using Verilog, chips have gotten a bit bigger--not physically, but in terms of transistor counts. Any guess how much "bigger"? 100x? 1000x? Not even close. 100,000x!!!

So we're ripe for change. We need circuit design to break out of its commercial fortress and discover what an open source ecosystem is capable of. And guess what. Having FPGAs in the cloud is going to release the flood gates. There have been three things holding back open source hardware:

  1. Circuit design is fundamentally harder than software. Sure, I said "it's just 1s and 0s," but, in contrast to software, the bulk of your development effort tends to focus on the implementation of the logic, not just the functionality.
  1. Access to hardware: Again, in contrast to software, you can't just download someone's RTL and use it. You have to turn it into hardware. For a hobbyist, that's not going to be an ASIC, so we're talking FPGAs. You've got to work this open-source RTL into your specific platform and your specific logic with your specific physical design constraints to make it do your bidding. You may as well start from scratch.
  1. Access to software: Unlike compilers for software, Electronic Design Automation (EDA) tools for compiling hardware are ***expensive***.

And I realized that all of these very serious obstacles were breaking down.

  1. I have greatly simplified hardware design with Redwood EDA, TL-Verilog, and Makerchip.
  2. Hardware access is totally solved by cloud FPGAs. Open source designs can be made available, packaged to run in hardware that is available to anyone! Just download, compile, and run in silicon, just like software.
  3. Other folks, like the almighty <a href="http://www.clifford.at/" target="_blank" atom_fix="_">Clifford Wolf</a>, have been developing open-source EDA tools, and FPGAs have now been designed exclusively using these open-source tools. Even commercially, with Amazon F1, Xilinx tools are now bundled with the platform using a rental model with no up-front cost. And my own Redwood EDA tools are free for open-source development at <a href="http://makerchip.com" target="_blank" atom_fix="_">makerchip.com</a> with no installation required.

This is game-changer! And it's a really refreshing one for me, having spent almost 20 years in an industry that was standing still. So I started ramping up on Amazon F1. Yikes! Holy crap! What a friggin' nightmare! The hardware platform was amazing, but the infrastructure for developing on the platform has a long way to go. So, I turned my attention elsewhere...

...until, I struck up a conversation with Marco Santambrogio at a conference. Marco heads the NECSTLab at Politecnico di Milano with reasearch on the Amazon F1 platform. We started a small collaboration leading to Alessandro Comodi's early contributions to the project. This was enough to draw my attention in this direction. And this year (2019), Google is helping the project along with Akos Hadnagy contributing through <a href="https://summerofcode.withgoogle.com/" target="_blank" atom_fix="_">Google Summer of Code</a>.

I hope you are able to benefit from the work. Please feed back into the project and become a "1st CLaaS citizen"--erg, did I really say that? Let me know what you are planning. Maybe I can help.

Happy coding!

_Steve Hoover_
