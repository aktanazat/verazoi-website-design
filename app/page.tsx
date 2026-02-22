import { Navbar } from "@/components/navbar"
import { ScrollProgress } from "@/components/scroll-progress"
import { Hero } from "@/components/hero"
import { PhoneMockup } from "@/components/phone-mockup"
import { PageSectionsTabs } from "@/components/page-sections-tabs"
import { Footer } from "@/components/footer"

export default function Home() {
  return (
    <main className="relative overflow-hidden">
      <ScrollProgress />
      <Navbar />
      <Hero />
      <PhoneMockup />
      <PageSectionsTabs />
      <Footer />
    </main>
  )
}
