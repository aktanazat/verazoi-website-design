"use client"

import { Component, type ReactNode } from "react"

type Props = { children: ReactNode }
type State = { hasError: boolean }

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false }

  static getDerivedStateFromError() {
    return { hasError: true }
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex min-h-[60vh] flex-col items-center justify-center px-6 text-center">
          <p className="text-[11px] font-medium uppercase tracking-[0.3em] text-muted-foreground">
            Something went wrong
          </p>
          <p className="mt-4 max-w-sm text-[13px] leading-relaxed text-muted-foreground/80">
            The app encountered an unexpected error. Try refreshing the page.
          </p>
          <button
            onClick={() => {
              this.setState({ hasError: false })
              window.location.reload()
            }}
            className="mt-6 border border-foreground bg-foreground px-6 py-2.5 text-[12px] font-medium tracking-wide text-background"
          >
            Reload
          </button>
        </div>
      )
    }

    return this.props.children
  }
}
