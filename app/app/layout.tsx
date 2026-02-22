import { AppNav } from "@/components/app-nav"
import { AppRouteTransition } from "@/components/app-route-transition"

export default function AppLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="flex min-h-[100dvh] flex-col bg-background">
      <AppNav />
      <main className="flex-1 px-5 pb-24 pt-6">
        <div className="mx-auto max-w-md">
          <AppRouteTransition>{children}</AppRouteTransition>
        </div>
      </main>
    </div>
  )
}
