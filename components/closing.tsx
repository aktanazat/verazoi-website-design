"use client"

import { useScrollReveal } from "@/hooks/use-scroll-reveal"

export function Closing() {
  const { ref, visible } = useScrollReveal(0.2)

  return (
    <section className="relative px-6 py-32 lg:py-44">
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-border to-transparent" />
        <div className="absolute left-1/2 top-1/2 h-[500px] w-[900px] -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary/[0.04] blur-[150px]" />
      </div>

      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_center,_var(--border)_1px,_transparent_1px)] [background-size:48px_48px] opacity-20" />

      <div ref={ref} className="relative mx-auto max-w-screen-lg text-center">
        <p
          className={`font-serif text-[clamp(2.5rem,6vw,5.5rem)] font-light leading-[1.05] tracking-tight transition-all duration-1000 ease-out ${
            visible ? "translate-y-0 opacity-100" : "translate-y-12 opacity-0"
          }`}
        >
          Verazoi
        </p>

        <p
          className={`mt-6 font-serif text-[clamp(1.1rem,2.2vw,1.5rem)] italic text-primary/70 transition-all duration-1000 delay-200 ease-out ${
            visible ? "translate-y-0 opacity-100" : "translate-y-8 opacity-0"
          }`}
        >
          Rooted in truth. Designed for life.
        </p>

        <div
          className={`mx-auto mt-10 max-w-md transition-all duration-1000 delay-400 ease-out ${
            visible ? "translate-y-0 opacity-100" : "translate-y-8 opacity-0"
          }`}
        >
          <p className="text-[14px] leading-relaxed text-muted-foreground">
            From <span className="font-serif italic text-foreground/80">Vera</span> (truth) and{" "}
            <span className="font-serif italic text-foreground/80">Zoi</span> (life) &mdash; our
            name reflects our commitment to delivering responsible, human-centered guidance. Not
            just metrics.
          </p>
        </div>
      </div>
    </section>
  )
}
